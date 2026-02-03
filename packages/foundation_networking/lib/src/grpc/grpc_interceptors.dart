import 'package:foundation_core/foundation_core.dart';
import 'package:grpc/grpc.dart';

/// Function that provides the current access token.
typedef TokenProvider = Future<String?> Function();

/// Function that refreshes the access token.
typedef TokenRefresher = Future<String?> Function();

/// gRPC interceptor that adds authentication headers.
class GrpcAuthInterceptor extends ClientInterceptor {
  final TokenProvider _tokenProvider;
  final AppLogger _log = AppLogger('GrpcAuthInterceptor');

  GrpcAuthInterceptor(this._tokenProvider);

  @override
  ResponseFuture<R> interceptUnary<Q, R>(
    ClientMethod<Q, R> method,
    Q request,
    CallOptions options,
    ClientUnaryInvoker<Q, R> invoker,
  ) {
    return _interceptCall(method, request, options, invoker);
  }

  @override
  ResponseStream<R> interceptStreaming<Q, R>(
    ClientMethod<Q, R> method,
    Stream<Q> requests,
    CallOptions options,
    ClientStreamingInvoker<Q, R> invoker,
  ) {
    // For streaming, we need to handle this differently
    // Get token synchronously or use empty and let the first call fail
    return invoker(method, requests, options);
  }

  ResponseFuture<R> _interceptCall<Q, R>(
    ClientMethod<Q, R> method,
    Q request,
    CallOptions options,
    ClientUnaryInvoker<Q, R> invoker,
  ) {
    // Create a new call that first gets the token
    return ResponseFuture<R>(
      _makeAuthenticatedCall(method, request, options, invoker),
    );
  }

  Future<R> _makeAuthenticatedCall<Q, R>(
    ClientMethod<Q, R> method,
    Q request,
    CallOptions options,
    ClientUnaryInvoker<Q, R> invoker,
  ) async {
    final token = await _tokenProvider();

    CallOptions newOptions = options;
    if (token != null && token.isNotEmpty) {
      newOptions = options.mergedWith(
        CallOptions(metadata: {'authorization': 'Bearer $token'}),
      );
      _log.debug('Added auth token to ${method.path}');
    }

    return await invoker(method, request, newOptions);
  }
}

/// gRPC interceptor that handles token refresh on 401 errors.
class GrpcRefreshInterceptor extends ClientInterceptor {
  final TokenProvider _tokenProvider;
  final TokenRefresher _tokenRefresher;
  final AppLogger _log = AppLogger('GrpcRefreshInterceptor');

  bool _isRefreshing = false;
  final List<Future<void> Function()> _pendingRequests = [];

  GrpcRefreshInterceptor({
    required TokenProvider tokenProvider,
    required TokenRefresher tokenRefresher,
  })  : _tokenProvider = tokenProvider,
        _tokenRefresher = tokenRefresher;

  @override
  ResponseFuture<R> interceptUnary<Q, R>(
    ClientMethod<Q, R> method,
    Q request,
    CallOptions options,
    ClientUnaryInvoker<Q, R> invoker,
  ) {
    return ResponseFuture<R>(
      _interceptWithRefresh(method, request, options, invoker),
    );
  }

  Future<R> _interceptWithRefresh<Q, R>(
    ClientMethod<Q, R> method,
    Q request,
    CallOptions options,
    ClientUnaryInvoker<Q, R> invoker,
  ) async {
    try {
      return await _makeCall(method, request, options, invoker);
    } on GrpcError catch (e) {
      if (e.code == StatusCode.unauthenticated) {
        _log.debug('Got 401, attempting token refresh');

        // Refresh token
        final newToken = await _refreshToken();
        if (newToken != null) {
          // Retry with new token
          _log.debug('Token refreshed, retrying request');
          return await _makeCall(method, request, options, invoker);
        }
      }
      rethrow;
    }
  }

  Future<R> _makeCall<Q, R>(
    ClientMethod<Q, R> method,
    Q request,
    CallOptions options,
    ClientUnaryInvoker<Q, R> invoker,
  ) async {
    final token = await _tokenProvider();

    CallOptions newOptions = options;
    if (token != null && token.isNotEmpty) {
      newOptions = options.mergedWith(
        CallOptions(metadata: {'authorization': 'Bearer $token'}),
      );
    }

    return await invoker(method, request, newOptions);
  }

  Future<String?> _refreshToken() async {
    if (_isRefreshing) {
      // Wait for ongoing refresh
      final completer = Future<void>(() {});
      _pendingRequests.add(() => completer);
      await completer;
      return _tokenProvider();
    }

    _isRefreshing = true;
    try {
      final newToken = await _tokenRefresher();

      // Process pending requests
      for (final pending in _pendingRequests) {
        pending();
      }
      _pendingRequests.clear();

      return newToken;
    } finally {
      _isRefreshing = false;
    }
  }
}

/// gRPC interceptor that logs requests and responses.
class GrpcLoggingInterceptor extends ClientInterceptor {
  final AppLogger _log;
  final bool logMetadata;
  final bool logRequest;
  final bool logResponse;

  GrpcLoggingInterceptor({
    String tag = 'gRPC',
    this.logMetadata = false,
    this.logRequest = false,
    this.logResponse = false,
  }) : _log = AppLogger(tag);

  @override
  ResponseFuture<R> interceptUnary<Q, R>(
    ClientMethod<Q, R> method,
    Q request,
    CallOptions options,
    ClientUnaryInvoker<Q, R> invoker,
  ) {
    final stopwatch = Stopwatch()..start();

    _log.debug('→ ${method.path}');
    if (logMetadata && options.metadata.isNotEmpty) {
      _log.debug('  Metadata: ${_sanitizeMetadata(options.metadata)}');
    }
    if (logRequest) {
      _log.debug('  Request: $request');
    }

    final response = invoker(method, request, options);

    response.then(
      (value) {
        stopwatch.stop();
        _log.debug('← ${method.path} [${stopwatch.elapsedMilliseconds}ms]');
        if (logResponse) {
          _log.debug('  Response: $value');
        }
      },
      onError: (error) {
        stopwatch.stop();
        _log.error('✕ ${method.path} [${stopwatch.elapsedMilliseconds}ms]', error);
      },
    );

    return response;
  }

  Map<String, String> _sanitizeMetadata(Map<String, String> metadata) {
    return metadata.map((key, value) {
      if (key.toLowerCase() == 'authorization') {
        return MapEntry(key, '***');
      }
      return MapEntry(key, value);
    });
  }
}

/// gRPC interceptor that adds custom metadata to all requests.
class GrpcMetadataInterceptor extends ClientInterceptor {
  final Map<String, String> Function() _metadataProvider;

  GrpcMetadataInterceptor(this._metadataProvider);

  /// Creates an interceptor with static metadata.
  factory GrpcMetadataInterceptor.static(Map<String, String> metadata) {
    return GrpcMetadataInterceptor(() => metadata);
  }

  @override
  ResponseFuture<R> interceptUnary<Q, R>(
    ClientMethod<Q, R> method,
    Q request,
    CallOptions options,
    ClientUnaryInvoker<Q, R> invoker,
  ) {
    final metadata = _metadataProvider();
    final newOptions = options.mergedWith(CallOptions(metadata: metadata));
    return invoker(method, request, newOptions);
  }

  @override
  ResponseStream<R> interceptStreaming<Q, R>(
    ClientMethod<Q, R> method,
    Stream<Q> requests,
    CallOptions options,
    ClientStreamingInvoker<Q, R> invoker,
  ) {
    final metadata = _metadataProvider();
    final newOptions = options.mergedWith(CallOptions(metadata: metadata));
    return invoker(method, requests, newOptions);
  }
}

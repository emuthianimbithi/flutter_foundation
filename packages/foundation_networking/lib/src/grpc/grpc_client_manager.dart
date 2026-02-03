import 'package:foundation_config/foundation_config.dart';
import 'package:foundation_core/foundation_core.dart';
import 'package:foundation_storage/foundation_storage.dart';
import 'package:grpc/grpc.dart';

import 'grpc_channel_factory.dart';
import 'grpc_error_mapper.dart';
import 'grpc_interceptors.dart';

/// Manages gRPC client connections and provides configured channels.
///
/// This is the main entry point for gRPC communication. It handles:
/// - Channel creation and lifecycle
/// - Authentication token injection
/// - Token refresh on 401 errors
/// - Error mapping
///
/// Example:
/// ```dart
/// final manager = GrpcClientManager(
///   config: grpcConfig,
///   secureStorage: secureStorage,
/// );
///
/// // Get a typed client (from your generated proto stubs)
/// final authClient = AuthServiceClient(
///   manager.channel,
///   options: manager.callOptions,
///   interceptors: manager.interceptors,
/// );
///
/// // Make calls with automatic auth and error handling
/// final result = await manager.wrapCall(() => authClient.login(request));
/// ```
class GrpcClientManager {
  final GrpcConfig _config;
  final SecureStorage _secureStorage;
  final AppLogger _log = AppLogger('GrpcClientManager');

  late final GrpcChannelFactory _channelFactory;
  final Map<Type, dynamic> _clientCache = {};

  /// Callback for handling auth failures (e.g., logout).
  void Function()? onAuthFailure;

  /// Callback for refreshing tokens.
  Future<bool> Function()? onTokenRefresh;

  GrpcClientManager({
    required GrpcConfig config,
    required SecureStorage secureStorage,
    this.onAuthFailure,
    this.onTokenRefresh,
    bool enableLogging = false,
  })  : _config = config,
        _secureStorage = secureStorage {
    _channelFactory = GrpcChannelFactoryBuilder()
        .withConfig(config)
        .withRefresh(
          tokenProvider: _getAccessToken,
          tokenRefresher: _refreshToken,
        )
        .withLogging(
          logMetadata: enableLogging,
          logRequest: enableLogging,
          logResponse: enableLogging,
        )
        .withMetadata(_getDefaultMetadata)
        .build();

    _log.info('GrpcClientManager initialized for ${config.url}');
  }

  /// The gRPC channel.
  ClientChannel get channel => _channelFactory.getChannel();

  /// Default call options.
  CallOptions get callOptions => _channelFactory.defaultCallOptions;

  /// The list of interceptors.
  List<ClientInterceptor> get interceptors => _channelFactory.interceptors;

  /// The gRPC configuration.
  GrpcConfig get config => _config;

  /// Gets or creates a cached client instance.
  ///
  /// Example:
  /// ```dart
  /// final authClient = manager.getClient<AuthServiceClient>(
  ///   () => AuthServiceClient(manager.channel, interceptors: manager.interceptors),
  /// );
  /// ```
  T getClient<T>(T Function() factory) {
    return _clientCache.putIfAbsent(T, factory) as T;
  }

  /// Clears the client cache.
  void clearClientCache() {
    _clientCache.clear();
  }

  /// Wraps a gRPC call with error handling, returning a [Result].
  Future<Result<T>> wrapCall<T>(Future<T> Function() call) async {
    try {
      final result = await call();
      return Result.success(result);
    } on GrpcError catch (e) {
      _log.error('gRPC error: ${e.code} - ${e.message}');

      // Handle auth failure
      if (e.code == StatusCode.unauthenticated) {
        onAuthFailure?.call();
      }

      return Result.failure(GrpcErrorMapper.mapGrpcError(e));
    } catch (e, s) {
      _log.error('Unexpected error in gRPC call', e, s);
      return Result.failure(Failure.unexpected(e.toString(), stackTrace: s));
    }
  }

  /// Wraps a gRPC call, throwing on error.
  Future<T> call<T>(Future<T> Function() grpcCall) async {
    try {
      return await grpcCall();
    } on GrpcError catch (e) {
      _log.error('gRPC error: ${e.code} - ${e.message}');

      if (e.code == StatusCode.unauthenticated) {
        onAuthFailure?.call();
      }

      throw GrpcErrorMapper.mapToNetworkException(e);
    }
  }

  /// Creates call options with a custom timeout.
  CallOptions callOptionsWithTimeout(Duration timeout) =>
      _channelFactory.callOptionsWithTimeout(timeout);

  Future<String?> _getAccessToken() async {
    return _secureStorage.getAccessToken();
  }

  Future<String?> _refreshToken() async {
    _log.debug('Attempting token refresh');

    if (onTokenRefresh == null) {
      _log.warning('No token refresh handler configured');
      return null;
    }

    final success = await onTokenRefresh!();
    if (success) {
      _log.debug('Token refresh successful');
      return _secureStorage.getAccessToken();
    } else {
      _log.warning('Token refresh failed');
      onAuthFailure?.call();
      return null;
    }
  }

  Map<String, String> _getDefaultMetadata() {
    return {
      'x-client-version': FoundationConfig.config.fullVersion,
      'x-app-id': FoundationConfig.config.appId,
    };
  }

  /// Shuts down the gRPC channel gracefully.
  Future<void> shutdown() async {
    _log.info('Shutting down GrpcClientManager');
    clearClientCache();
    await _channelFactory.shutdown();
  }

  /// Terminates the gRPC channel immediately.
  Future<void> terminate() async {
    _log.info('Terminating GrpcClientManager');
    clearClientCache();
    await _channelFactory.terminate();
  }
}

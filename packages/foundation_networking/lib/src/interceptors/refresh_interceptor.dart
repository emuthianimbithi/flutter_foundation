import 'dart:async';

import 'package:dio/dio.dart';
import 'package:foundation_core/foundation_core.dart';

/// Function that refreshes the access token.
typedef DioTokenRefresher = Future<String?> Function();

/// Function that provides the current access token.
typedef DioTokenProvider = Future<String?> Function();

/// Dio interceptor that handles token refresh on 401 errors.
class RefreshInterceptor extends Interceptor {
  final Dio _dio;
  final DioTokenProvider _tokenProvider;
  final DioTokenRefresher _tokenRefresher;
  final void Function()? _onAuthFailure;
  final AppLogger _log = AppLogger('RefreshInterceptor');

  bool _isRefreshing = false;
  final List<_PendingRequest> _pendingRequests = [];

  RefreshInterceptor({
    required Dio dio,
    required DioTokenProvider tokenProvider,
    required DioTokenRefresher tokenRefresher,
    void Function()? onAuthFailure,
  })  : _dio = dio,
        _tokenProvider = tokenProvider,
        _tokenRefresher = tokenRefresher,
        _onAuthFailure = onAuthFailure;

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    // Only handle 401 errors
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Skip if marked as no-auth or already retried
    if (err.requestOptions.extra['noAuth'] == true ||
        err.requestOptions.extra['isRetry'] == true) {
      return handler.next(err);
    }

    _log.debug('Got 401, attempting token refresh');

    // If already refreshing, queue this request
    if (_isRefreshing) {
      _log.debug('Refresh in progress, queueing request');
      return _queueRequest(err.requestOptions, handler);
    }

    _isRefreshing = true;

    try {
      final newToken = await _tokenRefresher();

      if (newToken != null) {
        _log.info('Token refresh successful');

        // Retry the original request
        final response = await _retryRequest(err.requestOptions, newToken);
        handler.resolve(response);

        // Process queued requests
        _processQueue(newToken);
      } else {
        _log.warning('Token refresh returned null');
        _onAuthFailure?.call();
        _failQueue(err);
        handler.next(err);
      }
    } catch (e) {
      _log.error('Token refresh failed', e);
      _onAuthFailure?.call();
      _failQueue(err);
      handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }

  void _queueRequest(RequestOptions options, ErrorInterceptorHandler handler) {
    _pendingRequests.add(_PendingRequest(options, handler));
  }

  void _processQueue(String token) {
    _log.debug('Processing ${_pendingRequests.length} queued requests');

    for (final pending in _pendingRequests) {
      _retryRequest(pending.options, token).then(
        (response) => pending.handler.resolve(response),
        onError: (e) {
          if (e is DioException) {
            pending.handler.reject(e);
          } else {
            pending.handler.reject(
              DioException(
                requestOptions: pending.options,
                error: e,
              ),
            );
          }
        },
      );
    }
    _pendingRequests.clear();
  }

  void _failQueue(DioException error) {
    _log.debug('Failing ${_pendingRequests.length} queued requests');

    for (final pending in _pendingRequests) {
      pending.handler.reject(
        DioException(
          requestOptions: pending.options,
          error: error.error,
          response: error.response,
          type: error.type,
        ),
      );
    }
    _pendingRequests.clear();
  }

  Future<Response<dynamic>> _retryRequest(
    RequestOptions options,
    String token,
  ) async {
    options.headers['Authorization'] = 'Bearer $token';
    options.extra['isRetry'] = true;

    _log.debug('Retrying request: ${options.uri.path}');

    return _dio.fetch(options);
  }
}

class _PendingRequest {
  final RequestOptions options;
  final ErrorInterceptorHandler handler;

  _PendingRequest(this.options, this.handler);
}

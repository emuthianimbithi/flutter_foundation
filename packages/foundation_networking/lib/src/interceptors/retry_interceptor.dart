import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:foundation_core/foundation_core.dart';

import '../core/retry_policy.dart';

/// Dio interceptor that retries failed requests based on a retry policy.
class RetryInterceptor extends Interceptor {
  final Dio _dio;
  final RetryPolicy _policy;
  final AppLogger _log = AppLogger('RetryInterceptor');

  RetryInterceptor({
    required Dio dio,
    RetryPolicy? policy,
  })  : _dio = dio,
        _policy = policy ?? RetryPolicy.defaults();

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    // Get current attempt from extra
    final attempt = (err.requestOptions.extra['retryAttempt'] as int?) ?? 0;

    // Check if we should retry
    if (!_shouldRetry(err, attempt)) {
      return handler.next(err);
    }

    // Calculate delay
    final delay = _policy.getDelay(attempt + 1);
    _log.debug(
      'Retrying request (attempt ${attempt + 1}/${_policy.maxRetries}) '
      'after ${delay.inMilliseconds}ms: ${err.requestOptions.uri.path}',
    );

    // Wait before retrying
    await Future<void>.delayed(delay);

    // Clone request options and increment attempt
    final options = err.requestOptions;
    options.extra['retryAttempt'] = attempt + 1;

    try {
      final response = await _dio.fetch(options);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  bool _shouldRetry(DioException err, int attempt) {
    // Check max retries
    if (attempt >= _policy.maxRetries) {
      return false;
    }

    // Don't retry if marked
    if (err.requestOptions.extra['noRetry'] == true) {
      return false;
    }

    // Check error type
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;

      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        if (statusCode != null) {
          return _policy.shouldRetryStatusCode(statusCode);
        }
        return false;

      case DioExceptionType.cancel:
        return false;

      case DioExceptionType.badCertificate:
        return false;

      case DioExceptionType.unknown:
        // Retry on socket/connection errors
        if (err.error is SocketException) {
          return true;
        }
        return false;
    }
  }
}

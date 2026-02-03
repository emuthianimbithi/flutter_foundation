import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:foundation_core/foundation_core.dart';

/// Dio interceptor that logs requests and responses.
class LoggingInterceptor extends Interceptor {
  final AppLogger _log;
  final bool logRequest;
  final bool logRequestHeaders;
  final bool logRequestBody;
  final bool logResponse;
  final bool logResponseHeaders;
  final bool logResponseBody;
  final bool logErrors;
  final int maxBodyLength;

  LoggingInterceptor({
    String tag = 'HTTP',
    this.logRequest = true,
    this.logRequestHeaders = false,
    this.logRequestBody = false,
    this.logResponse = true,
    this.logResponseHeaders = false,
    this.logResponseBody = false,
    this.logErrors = true,
    this.maxBodyLength = 1000,
  }) : _log = AppLogger(tag);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (logRequest) {
      _log.debug('→ ${options.method} ${options.uri}');

      if (logRequestHeaders && options.headers.isNotEmpty) {
        _log.debug('  Headers: ${_sanitizeHeaders(options.headers)}');
      }

      if (logRequestBody && options.data != null) {
        _log.debug('  Body: ${_truncate(_formatBody(options.data))}');
      }
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (logResponse) {
      final statusEmoji =
          response.statusCode != null && response.statusCode! < 400 ? '✓' : '✗';
      _log.debug(
        '← $statusEmoji ${response.statusCode} ${response.requestOptions.method} '
        '${response.requestOptions.uri.path}',
      );

      if (logResponseHeaders && response.headers.map.isNotEmpty) {
        _log.debug('  Headers: ${response.headers.map}');
      }

      if (logResponseBody && response.data != null) {
        _log.debug('  Body: ${_truncate(_formatBody(response.data))}');
      }
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (logErrors) {
      _log.error(
        '✗ ${err.response?.statusCode ?? 'ERR'} ${err.requestOptions.method} '
        '${err.requestOptions.uri.path}: ${err.message}',
      );

      if (err.response?.data != null) {
        _log.error(
            '  Error body: ${_truncate(_formatBody(err.response!.data))}');
      }
    }

    handler.next(err);
  }

  Map<String, dynamic> _sanitizeHeaders(Map<String, dynamic> headers) {
    return headers.map((key, value) {
      final lowerKey = key.toLowerCase();
      if (lowerKey == 'authorization' || lowerKey == 'cookie') {
        return MapEntry(key, '***');
      }
      return MapEntry(key, value);
    });
  }

  String _formatBody(dynamic body) {
    if (body == null) return 'null';
    if (body is String) return body;
    if (body is Map || body is List) {
      try {
        return const JsonEncoder.withIndent('  ').convert(body);
      } catch (_) {
        return body.toString();
      }
    }
    return body.toString();
  }

  String _truncate(String text) {
    if (text.length <= maxBodyLength) return text;
    return '${text.substring(0, maxBodyLength)}... [truncated]';
  }
}

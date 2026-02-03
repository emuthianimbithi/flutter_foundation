import 'package:dio/dio.dart';
import 'package:foundation_core/foundation_core.dart';

/// Function that provides the current access token.
typedef DioTokenProvider = Future<String?> Function();

/// Dio interceptor that adds authentication headers.
class AuthInterceptor extends Interceptor {
  final DioTokenProvider _tokenProvider;
  final String _headerName;
  final String _tokenPrefix;
  final AppLogger _log = AppLogger('AuthInterceptor');

  AuthInterceptor({
    required DioTokenProvider tokenProvider,
    String headerName = 'Authorization',
    String tokenPrefix = 'Bearer',
  })  : _tokenProvider = tokenProvider,
        _headerName = headerName,
        _tokenPrefix = tokenPrefix;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip if already has auth header
    if (options.headers.containsKey(_headerName)) {
      return handler.next(options);
    }

    // Skip if marked as no-auth
    if (options.extra['noAuth'] == true) {
      return handler.next(options);
    }

    final token = await _tokenProvider();
    if (token != null && token.isNotEmpty) {
      options.headers[_headerName] = '$_tokenPrefix $token';
      _log.debug('Added auth token to ${options.uri.path}');
    }

    handler.next(options);
  }
}

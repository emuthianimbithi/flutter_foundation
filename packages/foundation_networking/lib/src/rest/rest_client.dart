import 'package:dio/dio.dart';
import 'package:foundation_config/foundation_config.dart';
import 'package:foundation_core/foundation_core.dart';
import 'package:foundation_storage/foundation_storage.dart';

import '../core/cache_policy.dart';
import '../core/network_exceptions.dart';
import '../core/request_options.dart';
import '../core/retry_policy.dart';
import 'api_response.dart';
import 'dio_factory.dart';

/// High-level REST client with error handling and caching.
///
/// Example:
/// ```dart
/// final client = RestClient(
///   config: restConfig,
///   secureStorage: secureStorage,
///   database: database,
/// );
///
/// // GET request
/// final result = await client.get<Map<String, dynamic>>('/users/123');
///
/// // POST request
/// final createResult = await client.post<Map<String, dynamic>>(
///   '/users',
///   data: {'name': 'John'},
/// );
/// ```
class RestClient {
  final Dio _dio;
  final AppLogger _log = AppLogger('RestClient');

  /// Callback for handling auth failures.
  void Function()? onAuthFailure;

  RestClient._({
    required Dio dio,
    this.onAuthFailure,
  }) : _dio = dio;

  /// Creates a REST client with full configuration.
  factory RestClient({
    required RestConfig config,
    required SecureStorage secureStorage,
    required AppDatabase database,
    void Function()? onAuthFailure,
    Future<String?> Function()? onTokenRefresh,
    RetryPolicy? retryPolicy,
    CachePolicy? cachePolicy,
    bool enableLogging = false,
  }) {
    final dio = DioFactory.createWithInterceptors(
      config: config,
      secureStorage: secureStorage,
      database: database,
      onAuthFailure: onAuthFailure,
      onTokenRefresh: onTokenRefresh,
      retryPolicy: retryPolicy,
      cachePolicy: cachePolicy,
      enableLogging: enableLogging,
    );

    return RestClient._(dio: dio, onAuthFailure: onAuthFailure);
  }

  /// Creates a REST client with a pre-configured Dio instance.
  factory RestClient.withDio(Dio dio, {void Function()? onAuthFailure}) {
    return RestClient._(dio: dio, onAuthFailure: onAuthFailure);
  }

  /// The underlying Dio instance.
  Dio get dio => _dio;

  // ─────────────────────────────────────────────────────────────
  // HTTP METHODS
  // ─────────────────────────────────────────────────────────────

  /// Performs a GET request.
  Future<Result<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    NetworkRequestOptions? options,
  }) async {
    return _request<T>(
      'GET',
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Performs a POST request.
  Future<Result<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    NetworkRequestOptions? options,
  }) async {
    return _request<T>(
      'POST',
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Performs a PUT request.
  Future<Result<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    NetworkRequestOptions? options,
  }) async {
    return _request<T>(
      'PUT',
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Performs a PATCH request.
  Future<Result<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    NetworkRequestOptions? options,
  }) async {
    return _request<T>(
      'PATCH',
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Performs a DELETE request.
  Future<Result<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    NetworkRequestOptions? options,
  }) async {
    return _request<T>(
      'DELETE',
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Uploads a file.
  Future<Result<T>> upload<T>(
    String path,
    String filePath, {
    String fieldName = 'file',
    Map<String, dynamic>? additionalData,
    void Function(int sent, int total)? onProgress,
    NetworkRequestOptions? options,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        ...?additionalData,
      });

      final response = await _dio.post<T>(
        path,
        data: formData,
        options: _buildOptions(options),
        onSendProgress: onProgress,
      );

      return Result.success(response.data as T);
    } on DioException catch (e) {
      return Result.failure(_mapDioError(e));
    } catch (e, s) {
      _log.error('Upload error', e, s);
      return Result.failure(Failure.unexpected(e.toString(), stackTrace: s));
    }
  }

  /// Downloads a file.
  Future<Result<void>> download(
    String path,
    String savePath, {
    void Function(int received, int total)? onProgress,
    NetworkRequestOptions? options,
  }) async {
    try {
      await _dio.download(
        path,
        savePath,
        options: _buildOptions(options),
        onReceiveProgress: onProgress,
      );

      return Result.success(unit);
    } on DioException catch (e) {
      return Result.failure(_mapDioError(e));
    } catch (e, s) {
      _log.error('Download error', e, s);
      return Result.failure(Failure.unexpected(e.toString(), stackTrace: s));
    }
  }

  // ─────────────────────────────────────────────────────────────
  // INTERNAL
  // ─────────────────────────────────────────────────────────────

  Future<Result<T>> _request<T>(
    String method,
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    NetworkRequestOptions? options,
  }) async {
    try {
      final response = await _dio.request<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: _buildOptions(options)..method = method,
      );

      return Result.success(response.data as T);
    } on DioException catch (e) {
      final failure = _mapDioError(e);

      // Handle auth failure
      if (e.response?.statusCode == 401) {
        onAuthFailure?.call();
      }

      return Result.failure(failure);
    } catch (e, s) {
      _log.error('Request error', e, s);
      return Result.failure(Failure.unexpected(e.toString(), stackTrace: s));
    }
  }

  Options _buildOptions(NetworkRequestOptions? options) {
    return Options(
      headers: options?.headers,
      sendTimeout: options?.timeout,
      receiveTimeout: options?.timeout,
      extra: {
        if (options?.skipCache ?? false) 'skipCache': true,
        if (options?.forceRefresh ?? false) 'forceRefresh': true,
        if (!(options?.requiresAuth ?? true)) 'noAuth': true,
        ...?options?.metadata,
      },
    );
  }

  Failure _mapDioError(DioException error) {
    final exception = ApiResponse.fromDioError(error).exception;
    return exception?.toFailure() ??
        Failure.unexpected(error.message ?? 'Unknown error');
  }
}

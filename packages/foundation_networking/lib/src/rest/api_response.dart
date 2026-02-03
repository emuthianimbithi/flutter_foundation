import 'package:dio/dio.dart';
import 'package:foundation_core/foundation_core.dart';

import '../core/network_exceptions.dart';

/// Wrapper for API responses with success/failure handling.
class ApiResponse<T> {
  final T? data;
  final int? statusCode;
  final Map<String, dynamic>? headers;
  final bool fromCache;
  final String? errorMessage;
  final NetworkException? exception;

  const ApiResponse._({
    this.data,
    this.statusCode,
    this.headers,
    this.fromCache = false,
    this.errorMessage,
    this.exception,
  });

  /// Creates a successful response.
  factory ApiResponse.success(
    T data, {
    int? statusCode,
    Map<String, dynamic>? headers,
    bool fromCache = false,
  }) =>
      ApiResponse._(
        data: data,
        statusCode: statusCode,
        headers: headers,
        fromCache: fromCache,
      );

  /// Creates an error response.
  factory ApiResponse.error({
    int? statusCode,
    String? message,
    NetworkException? exception,
  }) =>
      ApiResponse._(
        statusCode: statusCode,
        errorMessage: message,
        exception: exception,
      );

  /// Creates from a Dio response.
  factory ApiResponse.fromDioResponse(Response<T> response) => ApiResponse._(
        data: response.data,
        statusCode: response.statusCode,
        headers: response.headers.map.map((k, v) => MapEntry(k, v.first)),
        fromCache: response.extra['fromCache'] == true,
      );

  /// Creates from a Dio error.
  factory ApiResponse.fromDioError(DioException error) {
    final statusCode = error.response?.statusCode;
    final message = _extractErrorMessage(error);
    final exception = _mapDioError(error);

    return ApiResponse._(
      statusCode: statusCode,
      errorMessage: message,
      exception: exception,
    );
  }

  /// Whether the response is successful.
  bool get isSuccess => exception == null && errorMessage == null;

  /// Whether the response is an error.
  bool get isError => !isSuccess;

  /// Converts to a [Result].
  Result<T> toResult() {
    if (isSuccess && data != null) {
      return Result.success(data as T);
    }

    final failure = exception?.toFailure() ??
        Failure.unexpected(errorMessage ?? 'Unknown error');
    return Result.failure(failure);
  }

  /// Gets data or throws.
  T getOrThrow() {
    if (isError) {
      throw exception ?? Exception(errorMessage);
    }
    return data as T;
  }

  /// Gets data or returns default.
  T getOrDefault(T defaultValue) {
    if (isError || data == null) {
      return defaultValue;
    }
    return data as T;
  }

  /// Maps the data if successful.
  ApiResponse<R> map<R>(R Function(T data) mapper) {
    if (isError || data == null) {
      return ApiResponse._(
        statusCode: statusCode,
        errorMessage: errorMessage,
        exception: exception,
      );
    }
    return ApiResponse.success(
      mapper(data as T),
      statusCode: statusCode,
      headers: headers,
      fromCache: fromCache,
    );
  }

  static String _extractErrorMessage(DioException error) {
    // Try to extract message from response body
    final responseData = error.response?.data;
    if (responseData is Map) {
      final message = responseData['message'] ??
          responseData['error'] ??
          responseData['detail'];
      if (message is String) return message;
    }

    // Fall back to Dio message
    return error.message ?? 'Network error';
  }

  static NetworkException _mapDioError(DioException error) {
    final statusCode = error.response?.statusCode;
    final message = _extractErrorMessage(error);

    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        TimeoutException(message: message, originalError: error),
      DioExceptionType.connectionError =>
        NoConnectionException(message: message, originalError: error),
      DioExceptionType.cancel =>
        CancelledException(message: message, originalError: error),
      DioExceptionType.badResponse when statusCode != null =>
        mapStatusCodeToException(
          statusCode,
          message,
          responseData: error.response?.data is Map
              ? error.response!.data as Map<String, dynamic>
              : null,
          originalError: error,
        ),
      _ => UnknownNetworkException(
          message: message,
          statusCode: statusCode,
          originalError: error,
        ),
    };
  }
}

/// Extension for wrapping Dio calls.
extension DioResponseExtension<T> on Future<Response<T>> {
  /// Wraps the response in an [ApiResponse].
  Future<ApiResponse<T>> toApiResponse() async {
    try {
      final response = await this;
      return ApiResponse.fromDioResponse(response);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  /// Wraps the response in a [Result].
  Future<Result<T>> toResult() async {
    final response = await toApiResponse();
    return response.toResult();
  }
}

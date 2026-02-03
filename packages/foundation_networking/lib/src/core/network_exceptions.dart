import 'package:foundation_core/foundation_core.dart';

/// Base class for network exceptions.
sealed class NetworkException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const NetworkException({
    required this.message,
    this.statusCode,
    this.originalError,
    this.stackTrace,
  });

  /// Converts this exception to a [Failure].
  Failure toFailure();

  @override
  String toString() => '$runtimeType: $message (status: $statusCode)';
}

/// No network connection.
class NoConnectionException extends NetworkException {
  const NoConnectionException({
    super.message = 'No internet connection',
    super.originalError,
    super.stackTrace,
  });

  @override
  Failure toFailure() => Failure.network(
        message,
        code: 'no_connection',
        originalException: originalError,
        stackTrace: stackTrace,
      );
}

/// Request timed out.
class TimeoutException extends NetworkException {
  const TimeoutException({
    super.message = 'Request timed out',
    super.originalError,
    super.stackTrace,
  });

  @override
  Failure toFailure() => Failure.timeout(message);
}

/// Request was cancelled.
class CancelledException extends NetworkException {
  const CancelledException({
    super.message = 'Request was cancelled',
    super.originalError,
    super.stackTrace,
  });

  @override
  Failure toFailure() => Failure.cancelled(message);
}

/// Server returned an error response.
class ServerException extends NetworkException {
  final Map<String, dynamic>? responseData;

  const ServerException({
    required super.message,
    required super.statusCode,
    this.responseData,
    super.originalError,
    super.stackTrace,
  });

  @override
  Failure toFailure() => Failure.server(
        message,
        code: statusCode?.toString(),
        details: responseData,
        originalException: originalError,
        stackTrace: stackTrace,
      );
}

/// Authentication failed (401).
class UnauthorizedException extends NetworkException {
  const UnauthorizedException({
    super.message = 'Unauthorized',
    super.statusCode = 401,
    super.originalError,
    super.stackTrace,
  });

  @override
  Failure toFailure() => Failure.authentication(
        message,
        code: statusCode?.toString(),
        originalException: originalError,
        stackTrace: stackTrace,
      );
}

/// Access forbidden (403).
class ForbiddenException extends NetworkException {
  const ForbiddenException({
    super.message = 'Access forbidden',
    super.statusCode = 403,
    super.originalError,
    super.stackTrace,
  });

  @override
  Failure toFailure() => Failure.authorization(
        message,
        code: statusCode?.toString(),
        originalException: originalError,
        stackTrace: stackTrace,
      );
}

/// Resource not found (404).
class NotFoundException extends NetworkException {
  const NotFoundException({
    super.message = 'Resource not found',
    super.statusCode = 404,
    super.originalError,
    super.stackTrace,
  });

  @override
  Failure toFailure() => Failure.notFound(
        message,
        code: statusCode?.toString(),
        originalException: originalError,
        stackTrace: stackTrace,
      );
}

/// Validation error (400/422).
class ValidationException extends NetworkException {
  final Map<String, List<String>>? fieldErrors;

  const ValidationException({
    required super.message,
    super.statusCode = 400,
    this.fieldErrors,
    super.originalError,
    super.stackTrace,
  });

  @override
  Failure toFailure() => Failure.validation(
        message,
        code: statusCode?.toString(),
        details: fieldErrors != null ? {'fields': fieldErrors} : null,
        originalException: originalError,
        stackTrace: stackTrace,
      );
}

/// Conflict error (409).
class ConflictException extends NetworkException {
  const ConflictException({
    required super.message,
    super.statusCode = 409,
    super.originalError,
    super.stackTrace,
  });

  @override
  Failure toFailure() => Failure.conflict(
        message,
        code: statusCode?.toString(),
        originalException: originalError,
        stackTrace: stackTrace,
      );
}

/// Rate limit exceeded (429).
class RateLimitException extends NetworkException {
  final Duration? retryAfter;

  const RateLimitException({
    super.message = 'Rate limit exceeded',
    super.statusCode = 429,
    this.retryAfter,
    super.originalError,
    super.stackTrace,
  });

  @override
  Failure toFailure() => Failure.rateLimit(message);
}

/// Service unavailable (503).
class ServiceUnavailableException extends NetworkException {
  const ServiceUnavailableException({
    super.message = 'Service unavailable',
    super.statusCode = 503,
    super.originalError,
    super.stackTrace,
  });

  @override
  Failure toFailure() => Failure.maintenance(message);
}

/// Unknown network error.
class UnknownNetworkException extends NetworkException {
  const UnknownNetworkException({
    required super.message,
    super.statusCode,
    super.originalError,
    super.stackTrace,
  });

  @override
  Failure toFailure() => Failure.unexpected(
        message,
        code: statusCode?.toString(),
        originalException: originalError,
        stackTrace: stackTrace,
      );
}

/// Maps HTTP status codes to exceptions.
NetworkException mapStatusCodeToException(
  int statusCode,
  String message, {
  Map<String, dynamic>? responseData,
  dynamic originalError,
  StackTrace? stackTrace,
}) {
  return switch (statusCode) {
    400 => ValidationException(
        message: message,
        statusCode: statusCode,
        originalError: originalError,
        stackTrace: stackTrace,
      ),
    401 => UnauthorizedException(
        message: message,
        statusCode: statusCode,
        originalError: originalError,
        stackTrace: stackTrace,
      ),
    403 => ForbiddenException(
        message: message,
        statusCode: statusCode,
        originalError: originalError,
        stackTrace: stackTrace,
      ),
    404 => NotFoundException(
        message: message,
        statusCode: statusCode,
        originalError: originalError,
        stackTrace: stackTrace,
      ),
    409 => ConflictException(
        message: message,
        statusCode: statusCode,
        originalError: originalError,
        stackTrace: stackTrace,
      ),
    422 => ValidationException(
        message: message,
        statusCode: statusCode,
        originalError: originalError,
        stackTrace: stackTrace,
      ),
    429 => RateLimitException(
        message: message,
        statusCode: statusCode,
        originalError: originalError,
        stackTrace: stackTrace,
      ),
    >= 500 && < 600 => statusCode == 503
        ? ServiceUnavailableException(
            message: message,
            statusCode: statusCode,
            originalError: originalError,
            stackTrace: stackTrace,
          )
        : ServerException(
            message: message,
            statusCode: statusCode,
            responseData: responseData,
            originalError: originalError,
            stackTrace: stackTrace,
          ),
    _ => UnknownNetworkException(
        message: message,
        statusCode: statusCode,
        originalError: originalError,
        stackTrace: stackTrace,
      ),
  };
}

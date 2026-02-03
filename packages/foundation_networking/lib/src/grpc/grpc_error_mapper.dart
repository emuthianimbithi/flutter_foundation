import 'package:foundation_core/foundation_core.dart';
import 'package:grpc/grpc.dart';

import '../core/network_exceptions.dart';

/// Maps gRPC errors to app-level failures and exceptions.
class GrpcErrorMapper {
  GrpcErrorMapper._();

  /// Maps a gRPC exception to a [Failure].
  static Failure mapGrpcError(GrpcError error) {
    final message = error.message ?? 'Unknown gRPC error';
    final code = error.code;

    return switch (code) {
      StatusCode.ok => Failure.unexpected('Unexpected OK status'),
      StatusCode.cancelled => Failure.cancelled(message),
      StatusCode.unknown => Failure.unexpected(message, code: 'grpc_unknown'),
      StatusCode.invalidArgument =>
        Failure.validation(message, code: 'invalid_argument'),
      StatusCode.deadlineExceeded => Failure.timeout(message),
      StatusCode.notFound => Failure.notFound(message, code: 'not_found'),
      StatusCode.alreadyExists =>
        Failure.conflict(message, code: 'already_exists'),
      StatusCode.permissionDenied =>
        Failure.authorization(message, code: 'permission_denied'),
      StatusCode.resourceExhausted => Failure.rateLimit(message),
      StatusCode.failedPrecondition =>
        Failure.validation(message, code: 'failed_precondition'),
      StatusCode.aborted => Failure.conflict(message, code: 'aborted'),
      StatusCode.outOfRange =>
        Failure.validation(message, code: 'out_of_range'),
      StatusCode.unimplemented =>
        Failure.server(message, code: 'unimplemented'),
      StatusCode.internal => Failure.server(message, code: 'internal'),
      StatusCode.unavailable => Failure.maintenance(message),
      StatusCode.dataLoss => Failure.server(message, code: 'data_loss'),
      StatusCode.unauthenticated =>
        Failure.authentication(message, code: 'unauthenticated'),
      _ => Failure.unexpected(message, code: 'grpc_$code'),
    };
  }

  /// Maps a gRPC exception to a [NetworkException].
  static NetworkException mapToNetworkException(GrpcError error) {
    final message = error.message ?? 'Unknown gRPC error';
    final code = error.code;

    return switch (code) {
      StatusCode.cancelled =>
        CancelledException(message: message, originalError: error),
      StatusCode.deadlineExceeded =>
        TimeoutException(message: message, originalError: error),
      StatusCode.notFound =>
        NotFoundException(message: message, originalError: error),
      StatusCode.alreadyExists =>
        ConflictException(message: message, originalError: error),
      StatusCode.permissionDenied =>
        ForbiddenException(message: message, originalError: error),
      StatusCode.resourceExhausted =>
        RateLimitException(message: message, originalError: error),
      StatusCode.unauthenticated =>
        UnauthorizedException(message: message, originalError: error),
      StatusCode.unavailable =>
        ServiceUnavailableException(message: message, originalError: error),
      StatusCode.invalidArgument ||
      StatusCode.failedPrecondition ||
      StatusCode.outOfRange =>
        ValidationException(message: message, originalError: error),
      StatusCode.internal ||
      StatusCode.unimplemented ||
      StatusCode.dataLoss =>
        ServerException(
          message: message,
          statusCode: _grpcCodeToHttp(code),
          originalError: error,
        ),
      _ => UnknownNetworkException(message: message, originalError: error),
    };
  }

  /// Converts gRPC status code to approximate HTTP status code.
  static int _grpcCodeToHttp(int grpcCode) {
    return switch (grpcCode) {
      StatusCode.ok => 200,
      StatusCode.cancelled => 499,
      StatusCode.unknown => 500,
      StatusCode.invalidArgument => 400,
      StatusCode.deadlineExceeded => 504,
      StatusCode.notFound => 404,
      StatusCode.alreadyExists => 409,
      StatusCode.permissionDenied => 403,
      StatusCode.resourceExhausted => 429,
      StatusCode.failedPrecondition => 400,
      StatusCode.aborted => 409,
      StatusCode.outOfRange => 400,
      StatusCode.unimplemented => 501,
      StatusCode.internal => 500,
      StatusCode.unavailable => 503,
      StatusCode.dataLoss => 500,
      StatusCode.unauthenticated => 401,
      _ => 500,
    };
  }

  /// Wraps a gRPC call and maps errors to [Result].
  static Future<Result<T>> wrapCall<T>(Future<T> Function() call) async {
    try {
      final result = await call();
      return Result.success(result);
    } on GrpcError catch (e) {
      return Result.failure(mapGrpcError(e));
    } catch (e, s) {
      return Result.failure(Failure.unexpected(e.toString(), stackTrace: s));
    }
  }

  /// Wraps a gRPC call and throws [NetworkException] on error.
  static Future<T> wrapCallThrows<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on GrpcError catch (e) {
      throw mapToNetworkException(e);
    }
  }
}

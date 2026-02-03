import 'package:equatable/equatable.dart';

/// Represents a failure that can occur in the application.
///
/// Failures are categorized by type to allow for different handling strategies.
///
/// Example:
/// ```dart
/// final failure = Failure.network('Connection timeout');
/// print(failure.message); // 'Connection timeout'
/// print(failure.type); // FailureType.network
///
/// // Pattern matching on failure type
/// switch (failure.type) {
///   case FailureType.network:
///     showNoConnectionDialog();
///   case FailureType.server:
///     showServerErrorSnackbar();
///   case FailureType.validation:
///     showValidationErrors(failure.details);
///   // ...
/// }
/// ```
class Failure extends Equatable {
  /// The type of failure.
  final FailureType type;

  /// Human-readable message describing the failure.
  final String message;

  /// Optional error code for programmatic handling.
  final String? code;

  /// Optional additional details about the failure.
  final Map<String, dynamic>? details;

  /// Optional stack trace for debugging.
  final StackTrace? stackTrace;

  /// Optional original exception that caused this failure.
  final Object? originalException;

  const Failure({
    required this.type,
    required this.message,
    this.code,
    this.details,
    this.stackTrace,
    this.originalException,
  });

  // ─────────────────────────────────────────────────────────────
  // FACTORY CONSTRUCTORS
  // ─────────────────────────────────────────────────────────────

  /// Creates a network failure (connection issues, timeouts, etc.).
  factory Failure.network(
    String message, {
    String? code,
    Map<String, dynamic>? details,
    StackTrace? stackTrace,
    Object? originalException,
  }) =>
      Failure(
        type: FailureType.network,
        message: message,
        code: code,
        details: details,
        stackTrace: stackTrace,
        originalException: originalException,
      );

  /// Creates a server failure (5xx errors, server-side issues).
  factory Failure.server(
    String message, {
    String? code,
    Map<String, dynamic>? details,
    StackTrace? stackTrace,
    Object? originalException,
  }) =>
      Failure(
        type: FailureType.server,
        message: message,
        code: code,
        details: details,
        stackTrace: stackTrace,
        originalException: originalException,
      );

  /// Creates an authentication failure (invalid credentials, expired token).
  factory Failure.authentication(
    String message, {
    String? code,
    Map<String, dynamic>? details,
    StackTrace? stackTrace,
    Object? originalException,
  }) =>
      Failure(
        type: FailureType.authentication,
        message: message,
        code: code,
        details: details,
        stackTrace: stackTrace,
        originalException: originalException,
      );

  /// Creates an authorization failure (insufficient permissions).
  factory Failure.authorization(
    String message, {
    String? code,
    Map<String, dynamic>? details,
    StackTrace? stackTrace,
    Object? originalException,
  }) =>
      Failure(
        type: FailureType.authorization,
        message: message,
        code: code,
        details: details,
        stackTrace: stackTrace,
        originalException: originalException,
      );

  /// Creates a validation failure (invalid input).
  factory Failure.validation(
    String message, {
    String? code,
    Map<String, dynamic>? details,
    StackTrace? stackTrace,
    Object? originalException,
  }) =>
      Failure(
        type: FailureType.validation,
        message: message,
        code: code,
        details: details,
        stackTrace: stackTrace,
        originalException: originalException,
      );

  /// Creates a not found failure (resource doesn't exist).
  factory Failure.notFound(
    String message, {
    String? code,
    Map<String, dynamic>? details,
    StackTrace? stackTrace,
    Object? originalException,
  }) =>
      Failure(
        type: FailureType.notFound,
        message: message,
        code: code,
        details: details,
        stackTrace: stackTrace,
        originalException: originalException,
      );

  /// Creates a conflict failure (duplicate, version mismatch).
  factory Failure.conflict(
    String message, {
    String? code,
    Map<String, dynamic>? details,
    StackTrace? stackTrace,
    Object? originalException,
  }) =>
      Failure(
        type: FailureType.conflict,
        message: message,
        code: code,
        details: details,
        stackTrace: stackTrace,
        originalException: originalException,
      );

  /// Creates a cache failure (cache miss, corruption).
  factory Failure.cache(
    String message, {
    String? code,
    Map<String, dynamic>? details,
    StackTrace? stackTrace,
    Object? originalException,
  }) =>
      Failure(
        type: FailureType.cache,
        message: message,
        code: code,
        details: details,
        stackTrace: stackTrace,
        originalException: originalException,
      );

  /// Creates a storage failure (database, file system).
  factory Failure.storage(
    String message, {
    String? code,
    Map<String, dynamic>? details,
    StackTrace? stackTrace,
    Object? originalException,
  }) =>
      Failure(
        type: FailureType.storage,
        message: message,
        code: code,
        details: details,
        stackTrace: stackTrace,
        originalException: originalException,
      );

  /// Creates an unexpected failure (unhandled exception).
  factory Failure.unexpected(
    String message, {
    String? code,
    Map<String, dynamic>? details,
    StackTrace? stackTrace,
    Object? originalException,
  }) =>
      Failure(
        type: FailureType.unexpected,
        message: message,
        code: code,
        details: details,
        stackTrace: stackTrace,
        originalException: originalException,
      );

  /// Creates a cancelled failure (user cancelled operation).
  factory Failure.cancelled([
    String message = 'Operation was cancelled',
  ]) =>
      Failure(
        type: FailureType.cancelled,
        message: message,
      );

  /// Creates a timeout failure.
  factory Failure.timeout([
    String message = 'Operation timed out',
  ]) =>
      Failure(
        type: FailureType.timeout,
        message: message,
      );

  /// Creates a rate limit failure.
  factory Failure.rateLimit([
    String message = 'Rate limit exceeded',
  ]) =>
      Failure(
        type: FailureType.rateLimit,
        message: message,
      );

  /// Creates a maintenance failure.
  factory Failure.maintenance([
    String message = 'Service is under maintenance',
  ]) =>
      Failure(
        type: FailureType.maintenance,
        message: message,
      );

  // ─────────────────────────────────────────────────────────────
  // HELPER METHODS
  // ─────────────────────────────────────────────────────────────

  /// Whether this failure is recoverable (user can retry).
  bool get isRecoverable => switch (type) {
        FailureType.network ||
        FailureType.timeout ||
        FailureType.server ||
        FailureType.rateLimit ||
        FailureType.maintenance =>
          true,
        _ => false,
      };

  /// Whether this failure requires re-authentication.
  bool get requiresReauth => type == FailureType.authentication;

  /// Creates a copy with modified properties.
  Failure copyWith({
    FailureType? type,
    String? message,
    String? code,
    Map<String, dynamic>? details,
    StackTrace? stackTrace,
    Object? originalException,
  }) =>
      Failure(
        type: type ?? this.type,
        message: message ?? this.message,
        code: code ?? this.code,
        details: details ?? this.details,
        stackTrace: stackTrace ?? this.stackTrace,
        originalException: originalException ?? this.originalException,
      );

  @override
  List<Object?> get props => [type, message, code, details];

  @override
  String toString() => 'Failure(type: $type, message: $message, code: $code)';
}

/// Types of failures that can occur.
enum FailureType {
  /// Network connectivity issues.
  network,

  /// Server-side errors (5xx).
  server,

  /// Authentication failed (invalid credentials, expired token).
  authentication,

  /// Authorization failed (insufficient permissions).
  authorization,

  /// Validation errors (invalid input).
  validation,

  /// Resource not found (404).
  notFound,

  /// Conflict (duplicate, version mismatch).
  conflict,

  /// Cache-related failures.
  cache,

  /// Storage/database failures.
  storage,

  /// Operation was cancelled by user.
  cancelled,

  /// Operation timed out.
  timeout,

  /// Rate limit exceeded.
  rateLimit,

  /// Service under maintenance.
  maintenance,

  /// Unexpected/unhandled error.
  unexpected,
}

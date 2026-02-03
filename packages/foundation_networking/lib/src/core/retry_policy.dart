import 'dart:math' as math;

import 'network_exceptions.dart';

/// Policy for retrying failed requests.
class RetryPolicy {
  /// Maximum number of retry attempts.
  final int maxRetries;

  /// Initial delay between retries.
  final Duration initialDelay;

  /// Maximum delay between retries.
  final Duration maxDelay;

  /// Multiplier for exponential backoff.
  final double backoffMultiplier;

  /// Whether to add jitter to delay.
  final bool useJitter;

  /// HTTP status codes that should trigger a retry.
  final Set<int> retryableStatusCodes;

  /// Exception types that should trigger a retry.
  final bool Function(Object error)? shouldRetryOn;

  const RetryPolicy({
    this.maxRetries = 3,
    this.initialDelay = const Duration(milliseconds: 500),
    this.maxDelay = const Duration(seconds: 30),
    this.backoffMultiplier = 2.0,
    this.useJitter = true,
    this.retryableStatusCodes = const {408, 429, 500, 502, 503, 504},
    this.shouldRetryOn,
  });

  /// No retries.
  factory RetryPolicy.none() => const RetryPolicy(maxRetries: 0);

  /// Default retry policy.
  factory RetryPolicy.defaults() => const RetryPolicy();

  /// Aggressive retry policy.
  factory RetryPolicy.aggressive() => const RetryPolicy(
        maxRetries: 5,
        initialDelay: Duration(milliseconds: 200),
        maxDelay: Duration(minutes: 2),
      );

  /// Calculates the delay for a retry attempt.
  Duration getDelay(int attempt) {
    if (attempt <= 0) return Duration.zero;

    // Exponential backoff
    var delay = initialDelay * math.pow(backoffMultiplier, attempt - 1);

    // Cap at max delay
    if (delay > maxDelay) {
      delay = maxDelay;
    }

    // Add jitter (±25%)
    if (useJitter) {
      final jitter = delay.inMilliseconds * 0.25;
      final random = math.Random();
      final jitterMs = (random.nextDouble() * jitter * 2) - jitter;
      delay = Duration(milliseconds: delay.inMilliseconds + jitterMs.round());
    }

    return delay;
  }

  /// Whether a status code should be retried.
  bool shouldRetryStatusCode(int statusCode) {
    return retryableStatusCodes.contains(statusCode);
  }

  /// Whether an error should trigger a retry.
  bool shouldRetry(Object error, int attempt) {
    if (attempt >= maxRetries) return false;

    // Custom retry condition
    if (shouldRetryOn != null) {
      return shouldRetryOn!(error);
    }

    // Default: retry on network errors
    if (error is NoConnectionException) return true;
    if (error is TimeoutException) return true;
    if (error is ServiceUnavailableException) return true;
    if (error is RateLimitException) return true;

    // Retry on server errors
    if (error is ServerException) {
      return shouldRetryStatusCode(error.statusCode ?? 0);
    }

    return false;
  }

  /// Creates a copy with modified settings.
  RetryPolicy copyWith({
    int? maxRetries,
    Duration? initialDelay,
    Duration? maxDelay,
    double? backoffMultiplier,
    bool? useJitter,
    Set<int>? retryableStatusCodes,
    bool Function(Object error)? shouldRetryOn,
  }) =>
      RetryPolicy(
        maxRetries: maxRetries ?? this.maxRetries,
        initialDelay: initialDelay ?? this.initialDelay,
        maxDelay: maxDelay ?? this.maxDelay,
        backoffMultiplier: backoffMultiplier ?? this.backoffMultiplier,
        useJitter: useJitter ?? this.useJitter,
        retryableStatusCodes: retryableStatusCodes ?? this.retryableStatusCodes,
        shouldRetryOn: shouldRetryOn ?? this.shouldRetryOn,
      );
}

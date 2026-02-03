import 'dart:async';

/// Extension methods for [Future].
extension FutureExtensions<T> on Future<T> {
  /// Maps the result of this future using [transform].
  Future<R> mapTo<R>(R Function(T value) transform) async =>
      transform(await this);

  /// Ignores the result of this future.
  Future<void> get ignoreResult async {
    await this;
  }

  /// Returns null if this future throws an error.
  Future<T?> get orNull async {
    try {
      return await this;
    } catch (_) {
      return null;
    }
  }

  /// Returns [defaultValue] if this future throws an error.
  Future<T> onError(T defaultValue) async {
    try {
      return await this;
    } catch (_) {
      return defaultValue;
    }
  }

  /// Returns the result of [fallback] if this future throws an error.
  Future<T> onErrorThen(Future<T> Function(Object error) fallback) async {
    try {
      return await this;
    } catch (e) {
      return fallback(e);
    }
  }

  /// Executes [action] with the result and returns the original result.
  Future<T> tap(void Function(T value) action) async {
    final value = await this;
    action(value);
    return value;
  }

  /// Executes [action] with the result asynchronously and returns the original result.
  Future<T> tapAsync(Future<void> Function(T value) action) async {
    final value = await this;
    await action(value);
    return value;
  }

  /// Times out after [duration], returning [onTimeout] result.
  Future<T?> timeoutOrNull(
    Duration duration, {
    T? onTimeout,
  }) async {
    try {
      return await timeout(duration);
    } on TimeoutException {
      return onTimeout;
    }
  }

  /// Delays the completion of this future by [duration].
  Future<T> delayed(Duration duration) async {
    final result = await this;
    await Future<void>.delayed(duration);
    return result;
  }

  /// Ensures this future takes at least [minDuration] to complete.
  Future<T> minDuration(Duration minDuration) async {
    final stopwatch = Stopwatch()..start();
    final result = await this;
    stopwatch.stop();
    final remaining = minDuration - stopwatch.elapsed;
    if (remaining.isNegative) return result;
    await Future<void>.delayed(remaining);
    return result;
  }
}

/// Extension methods for [Future] of nullable values.
extension FutureNullableExtensions<T> on Future<T?> {
  /// Throws [error] if the result is null.
  Future<T> orThrow(Object error) async {
    final value = await this;
    if (value == null) throw error;
    return value;
  }

  /// Returns [defaultValue] if the result is null.
  Future<T> orDefault(T defaultValue) async {
    final value = await this;
    return value ?? defaultValue;
  }
}

/// Extension methods for [Future] of [bool].
extension FutureBoolExtensions on Future<bool> {
  /// Returns the logical AND of this future and [other].
  Future<bool> and(Future<bool> other) async => await this && await other;

  /// Returns the logical OR of this future and [other].
  Future<bool> or(Future<bool> other) async => await this || await other;

  /// Returns the logical NOT of this future.
  Future<bool> get not async => !(await this);
}

/// Extension methods for creating delayed futures.
extension FutureDelayExtension on Duration {
  /// Creates a future that completes after this duration.
  Future<void> get delay => Future.delayed(this);

  /// Creates a future that completes with [value] after this duration.
  Future<T> delayedValue<T>(T value) => Future.delayed(this, () => value);

  /// Creates a future that computes [computation] after this duration.
  Future<T> delayedComputation<T>(T Function() computation) =>
      Future.delayed(this, computation);
}

/// Utilities for working with multiple futures.
class FutureUtils {
  FutureUtils._();

  /// Waits for all futures and returns results, including errors.
  static Future<List<(T?, Object?)>> settleAll<T>(
    Iterable<Future<T>> futures,
  ) async {
    final results = <(T?, Object?)>[];
    for (final future in futures) {
      try {
        results.add((await future, null));
      } catch (e) {
        results.add((null, e));
      }
    }
    return results;
  }

  /// Waits for the first future to complete successfully.
  static Future<T> any<T>(Iterable<Future<T>> futures) async {
    final completer = Completer<T>();
    var errorCount = 0;
    final totalCount = futures.length;
    Object? lastError;

    for (final future in futures) {
      // ignore: unawaited_futures
      future.then(
        (value) {
          if (!completer.isCompleted) {
            completer.complete(value);
          }
        },
        onError: (Object error) {
          errorCount++;
          lastError = error;
          if (errorCount == totalCount && !completer.isCompleted) {
            completer.completeError(lastError!);
          }
        },
      );
    }

    return completer.future;
  }

  /// Retries a future-returning function with exponential backoff.
  static Future<T> retry<T>(
    Future<T> Function() fn, {
    int maxAttempts = 3,
    Duration initialDelay = const Duration(milliseconds: 100),
    double backoffMultiplier = 2.0,
    bool Function(Object error)? shouldRetry,
  }) async {
    var attempt = 0;
    var delay = initialDelay;

    while (true) {
      try {
        return await fn();
      } catch (e) {
        attempt++;
        if (attempt >= maxAttempts) rethrow;
        if (shouldRetry != null && !shouldRetry(e)) rethrow;
        await Future<void>.delayed(delay);
        delay *= backoffMultiplier;
      }
    }
  }
}

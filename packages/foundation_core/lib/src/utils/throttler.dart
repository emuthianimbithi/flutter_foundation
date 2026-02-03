import 'dart:async';

/// A utility class for throttling function calls.
///
/// Throttling ensures that a function is called at most once per
/// specified duration.
///
/// Example:
/// ```dart
/// final throttler = Throttler(duration: Duration(milliseconds: 100));
///
/// // In a scroll listener:
/// onScroll: (offset) {
///   throttler.run(() {
///     // This will be called at most once every 100ms
///     updateUI(offset);
///   });
/// }
///
/// // Don't forget to dispose when done:
/// throttler.dispose();
/// ```
class Throttler {
  /// The minimum duration between calls.
  final Duration duration;

  /// Whether to call on the leading edge.
  final bool leading;

  /// Whether to call on the trailing edge.
  final bool trailing;

  Timer? _timer;
  DateTime? _lastCall;
  void Function()? _pendingAction;

  /// Creates a throttler with the specified [duration].
  Throttler({
    required this.duration,
    this.leading = true,
    this.trailing = true,
  });

  /// Creates a throttler with a duration in milliseconds.
  factory Throttler.milliseconds(
    int milliseconds, {
    bool leading = true,
    bool trailing = true,
  }) =>
      Throttler(
        duration: Duration(milliseconds: milliseconds),
        leading: leading,
        trailing: trailing,
      );

  /// Runs [action] if enough time has passed since the last call.
  void run(void Function() action) {
    final now = DateTime.now();

    if (_lastCall == null) {
      // First call
      if (leading) {
        action();
        _lastCall = now;
      } else {
        _pendingAction = action;
        _scheduleTrailing();
      }
      return;
    }

    final elapsed = now.difference(_lastCall!);

    if (elapsed >= duration) {
      // Enough time has passed
      action();
      _lastCall = now;
      _timer?.cancel();
      _timer = null;
      _pendingAction = null;
    } else if (trailing) {
      // Schedule trailing call
      _pendingAction = action;
      _scheduleTrailing();
    }
  }

  void _scheduleTrailing() {
    if (_timer != null) return;

    final remaining =
        duration - DateTime.now().difference(_lastCall ?? DateTime.now());
    _timer = Timer(remaining.isNegative ? Duration.zero : remaining, () {
      if (_pendingAction != null) {
        _pendingAction!();
        _lastCall = DateTime.now();
        _pendingAction = null;
      }
      _timer = null;
    });
  }

  /// Cancels any pending trailing call.
  void cancel() {
    _timer?.cancel();
    _timer = null;
    _pendingAction = null;
  }

  /// Resets the throttler state.
  void reset() {
    cancel();
    _lastCall = null;
  }

  /// Whether there is a pending trailing call.
  bool get isPending => _pendingAction != null;

  /// Disposes the throttler.
  void dispose() {
    cancel();
  }
}

/// A throttler that can be called like a function.
///
/// Example:
/// ```dart
/// final throttledScroll = CallableThrottler<double>(
///   duration: Duration(milliseconds: 100),
///   action: (offset) => updateUI(offset),
/// );
///
/// // Usage:
/// throttledScroll(scrollOffset);
/// ```
class CallableThrottler<T> {
  /// The minimum duration between calls.
  final Duration duration;

  /// The action to execute.
  final void Function(T value) action;

  /// Whether to call on the leading edge.
  final bool leading;

  /// Whether to call on the trailing edge.
  final bool trailing;

  Timer? _timer;
  DateTime? _lastCall;
  T? _pendingValue;

  /// Creates a callable throttler.
  CallableThrottler({
    required this.duration,
    required this.action,
    this.leading = true,
    this.trailing = true,
  });

  /// Schedules [action] to be called with [value].
  void call(T value) {
    final now = DateTime.now();

    if (_lastCall == null) {
      if (leading) {
        action(value);
        _lastCall = now;
      } else {
        _pendingValue = value;
        _scheduleTrailing();
      }
      return;
    }

    final elapsed = now.difference(_lastCall!);

    if (elapsed >= duration) {
      action(value);
      _lastCall = now;
      _timer?.cancel();
      _timer = null;
      _pendingValue = null;
    } else if (trailing) {
      _pendingValue = value;
      _scheduleTrailing();
    }
  }

  void _scheduleTrailing() {
    if (_timer != null) return;

    final remaining =
        duration - DateTime.now().difference(_lastCall ?? DateTime.now());
    _timer = Timer(remaining.isNegative ? Duration.zero : remaining, () {
      if (_pendingValue != null) {
        action(_pendingValue as T);
        _lastCall = DateTime.now();
        _pendingValue = null;
      }
      _timer = null;
    });
  }

  /// Cancels any pending call.
  void cancel() {
    _timer?.cancel();
    _timer = null;
    _pendingValue = null;
  }

  /// Disposes the throttler.
  void dispose() {
    cancel();
  }
}

/// Extension to add throttle to any function.
extension ThrottleExtension<T> on void Function(T) {
  /// Creates a throttled version of this function.
  CallableThrottler<T> throttled(Duration duration) =>
      CallableThrottler<T>(duration: duration, action: this);
}

import 'dart:async';

/// A utility class for debouncing function calls.
///
/// Debouncing ensures that a function is only called after a specified
/// duration has passed since the last call.
///
/// Example:
/// ```dart
/// final debouncer = Debouncer(duration: Duration(milliseconds: 300));
///
/// // In a text field onChange:
/// onChanged: (value) {
///   debouncer.run(() {
///     // This will only be called 300ms after the user stops typing
///     searchApi(value);
///   });
/// }
///
/// // Don't forget to dispose when done:
/// debouncer.dispose();
/// ```
class Debouncer {
  /// The duration to wait before executing the action.
  final Duration duration;

  Timer? _timer;

  /// Creates a debouncer with the specified [duration].
  Debouncer({required this.duration});

  /// Creates a debouncer with a duration in milliseconds.
  factory Debouncer.milliseconds(int milliseconds) =>
      Debouncer(duration: Duration(milliseconds: milliseconds));

  /// Creates a debouncer with a duration in seconds.
  factory Debouncer.seconds(int seconds) =>
      Debouncer(duration: Duration(seconds: seconds));

  /// Runs [action] after [duration] has passed since the last call.
  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  /// Runs [action] after [duration] and returns a Future with the result.
  Future<T> runAsync<T>(Future<T> Function() action) {
    final completer = Completer<T>();
    run(() async {
      try {
        completer.complete(await action());
      } catch (e, s) {
        completer.completeError(e, s);
      }
    });
    return completer.future;
  }

  /// Cancels any pending action.
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Whether there is a pending action.
  bool get isPending => _timer?.isActive ?? false;

  /// Disposes the debouncer and cancels any pending action.
  void dispose() {
    cancel();
  }
}

/// A debouncer that can be called like a function.
///
/// Example:
/// ```dart
/// final debouncedSearch = CallableDebouncer<String>(
///   duration: Duration(milliseconds: 300),
///   action: (query) => searchApi(query),
/// );
///
/// // Usage:
/// debouncedSearch('search term');
/// ```
class CallableDebouncer<T> {
  /// The duration to wait before executing the action.
  final Duration duration;

  /// The action to execute.
  final void Function(T value) action;

  Timer? _timer;
  T? _lastValue;

  /// Creates a callable debouncer.
  CallableDebouncer({
    required this.duration,
    required this.action,
  });

  /// Schedules [action] to be called with [value].
  void call(T value) {
    _lastValue = value;
    _timer?.cancel();
    _timer = Timer(duration, () {
      if (_lastValue != null) {
        action(_lastValue as T);
      }
    });
  }

  /// Cancels any pending action.
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Executes the action immediately with the last value.
  void flush() {
    _timer?.cancel();
    _timer = null;
    if (_lastValue != null) {
      action(_lastValue as T);
    }
  }

  /// Disposes the debouncer.
  void dispose() {
    cancel();
    _lastValue = null;
  }
}

/// Extension to add debounce to any function.
extension DebounceExtension<T> on void Function(T) {
  /// Creates a debounced version of this function.
  CallableDebouncer<T> debounced(Duration duration) =>
      CallableDebouncer<T>(duration: duration, action: this);
}

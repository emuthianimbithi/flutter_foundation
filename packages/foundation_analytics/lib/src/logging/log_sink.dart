import 'log_level.dart';

abstract class LogSink {
  const LogSink();
  Future<void> log(LogLevel level, String message,
      {Object? error, StackTrace? stackTrace});
}

class ConsoleLogSink extends LogSink {
  const ConsoleLogSink();

  @override
  Future<void> log(LogLevel level, String message,
      {Object? error, StackTrace? stackTrace}) async {
    // ignore: avoid_print
    print('[${level.name.toUpperCase()}] $message');
    if (error != null) {
      // ignore: avoid_print
      print('  error: $error');
    }
    if (stackTrace != null) {
      // ignore: avoid_print
      print('  stack: $stackTrace');
    }
  }
}

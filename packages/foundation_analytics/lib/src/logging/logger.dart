import 'log_level.dart';
import 'log_sink.dart';

class Logger {
  final List<LogSink> _sinks;

  Logger({List<LogSink>? sinks}) : _sinks = sinks ?? const [ConsoleLogSink()];

  Future<void> debug(String message, {Object? error, StackTrace? stackTrace}) =>
      _emit(LogLevel.debug, message, error: error, stackTrace: stackTrace);

  Future<void> info(String message, {Object? error, StackTrace? stackTrace}) =>
      _emit(LogLevel.info, message, error: error, stackTrace: stackTrace);

  Future<void> warn(String message, {Object? error, StackTrace? stackTrace}) =>
      _emit(LogLevel.warn, message, error: error, stackTrace: stackTrace);

  Future<void> error(String message, {Object? error, StackTrace? stackTrace}) =>
      _emit(LogLevel.error, message, error: error, stackTrace: stackTrace);

  Future<void> _emit(LogLevel level, String message,
      {Object? error, StackTrace? stackTrace}) async {
    for (final sink in _sinks) {
      await sink.log(level, message, error: error, stackTrace: stackTrace);
    }
  }
}

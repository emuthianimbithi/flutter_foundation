import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart' as pkg_logger;

/// Application logger with support for different log levels and formatting.
///
/// Example:
/// ```dart
/// final log = AppLogger('MyClass');
///
/// log.debug('Debug message');
/// log.info('Info message');
/// log.warning('Warning message');
/// log.error('Error message', error, stackTrace);
/// ```
class AppLogger {
  /// The tag for this logger instance.
  final String tag;

  /// The underlying logger instance.
  static late pkg_logger.Logger _logger;

  /// Whether logging is enabled globally.
  static bool _enabled = true;

  /// The minimum log level.
  static LogLevel _minLevel = LogLevel.debug;

  /// Initializes the logger with configuration.
  static void init({
    bool enabled = true,
    LogLevel minLevel = LogLevel.debug,
    bool printTime = true,
    bool printEmoji = true,
  }) {
    _enabled = enabled;
    _minLevel = minLevel;

    final filter = _MinLevelFilter(minLevel);
    final printer = pkg_logger.PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: printEmoji,
      dateTimeFormat: printTime ? pkg_logger.DateTimeFormat.onlyTimeAndSinceStart : pkg_logger.DateTimeFormat.none,
    );

    _logger = pkg_logger.Logger(
      filter: filter,
      printer: printer,
      output: pkg_logger.ConsoleOutput(),
    );
  }

  /// Creates a logger with the given [tag].
  AppLogger(this.tag) {
    // Ensure logger is initialized
    if (!_isInitialized) {
      init(enabled: kDebugMode);
      _isInitialized = true;
    }
  }

  static bool _isInitialized = false;

  /// Creates a logger for a class type.
  factory AppLogger.forType(Type type) => AppLogger(type.toString());

  /// Enables or disables logging globally.
  static set enabled(bool value) => _enabled = value;

  /// Gets whether logging is enabled.
  static bool get enabled => _enabled;

  /// Sets the minimum log level.
  static set minLevel(LogLevel level) {
    _minLevel = level;
    init(
      enabled: _enabled,
      minLevel: level,
    );
  }

  String _formatMessage(String message) => '[$tag] $message';

  /// Logs a debug message.
  void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    if (!_enabled || _minLevel.index > LogLevel.debug.index) return;
    _logger.d(_formatMessage(message), error: error, stackTrace: stackTrace);
  }

  /// Logs an info message.
  void info(String message, [dynamic error, StackTrace? stackTrace]) {
    if (!_enabled || _minLevel.index > LogLevel.info.index) return;
    _logger.i(_formatMessage(message), error: error, stackTrace: stackTrace);
  }

  /// Logs a warning message.
  void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    if (!_enabled || _minLevel.index > LogLevel.warning.index) return;
    _logger.w(_formatMessage(message), error: error, stackTrace: stackTrace);
  }

  /// Logs an error message.
  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (!_enabled || _minLevel.index > LogLevel.error.index) return;
    _logger.e(_formatMessage(message), error: error, stackTrace: stackTrace);
  }

  /// Logs a fatal/critical message.
  void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    if (!_enabled) return;
    _logger.f(_formatMessage(message), error: error, stackTrace: stackTrace);
  }

  /// Logs a trace message (verbose).
  void trace(String message, [dynamic error, StackTrace? stackTrace]) {
    if (!_enabled || _minLevel.index > LogLevel.trace.index) return;
    _logger.t(_formatMessage(message), error: error, stackTrace: stackTrace);
  }

  /// Logs a message at the specified level.
  void log(LogLevel level, String message, [dynamic error, StackTrace? stackTrace]) {
    switch (level) {
      case LogLevel.trace:
        trace(message, error, stackTrace);
      case LogLevel.debug:
        debug(message, error, stackTrace);
      case LogLevel.info:
        info(message, error, stackTrace);
      case LogLevel.warning:
        warning(message, error, stackTrace);
      case LogLevel.error:
        error(message, error, stackTrace);
      case LogLevel.fatal:
        fatal(message, error, stackTrace);
    }
  }
}

/// Log levels.
enum LogLevel {
  /// Verbose logging.
  trace,

  /// Debug logging.
  debug,

  /// Informational logging.
  info,

  /// Warning logging.
  warning,

  /// Error logging.
  error,

  /// Fatal/critical logging.
  fatal,
}

class _MinLevelFilter extends pkg_logger.LogFilter {
  final LogLevel minLevel;

  _MinLevelFilter(this.minLevel);

  @override
  bool shouldLog(pkg_logger.LogEvent event) {
    final eventLevel = switch (event.level) {
      pkg_logger.Level.trace => LogLevel.trace,
      pkg_logger.Level.debug => LogLevel.debug,
      pkg_logger.Level.info => LogLevel.info,
      pkg_logger.Level.warning => LogLevel.warning,
      pkg_logger.Level.error => LogLevel.error,
      pkg_logger.Level.fatal => LogLevel.fatal,
      _ => LogLevel.debug,
    };
    return eventLevel.index >= minLevel.index;
  }
}

/// Global logger instance.
final log = AppLogger('App');

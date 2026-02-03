import 'crash_reporter.dart';

class CrashService {
  final CrashReporter _reporter;

  const CrashService(this._reporter);

  Future<void> setUser(String? userId) => _reporter.setUserId(userId);

  Future<void> record(Object error, StackTrace stackTrace, {String? reason, bool fatal = false}) {
    return _reporter.recordError(error, stackTrace, reason: reason, fatal: fatal);
  }
}
abstract class CrashReporter {
  const CrashReporter();

  Future<void> setUserId(String? userId);
  Future<void> recordError(Object error, StackTrace stackTrace,
      {String? reason, bool fatal = false});
}

class NoopCrashReporter extends CrashReporter {
  const NoopCrashReporter();

  @override
  Future<void> setUserId(String? userId) async {}

  @override
  Future<void> recordError(Object error, StackTrace stackTrace,
      {String? reason, bool fatal = false}) async {}
}

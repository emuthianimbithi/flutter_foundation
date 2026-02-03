abstract class CrashReportingService {
  Future<void> recordError(Object error, StackTrace stackTrace);
}
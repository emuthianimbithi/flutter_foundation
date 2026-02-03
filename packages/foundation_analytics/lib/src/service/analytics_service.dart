abstract class AnalyticsService {
  Future<void> logEvent(String name,
      {Map<String, Object?> parameters = const {}});
  Future<void> setUserId(String? userId);
  Future<void> setUserProperties(Map<String, Object?> properties);
}

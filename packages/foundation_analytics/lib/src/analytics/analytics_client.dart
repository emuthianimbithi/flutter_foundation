import '../models/analytics_event.dart';

abstract class AnalyticsClient {
  const AnalyticsClient();

  Future<void> setUserId(String? userId);
  Future<void> setUserProperties(Map<String, Object?> properties);
  Future<void> track(AnalyticsEvent event);
}

class NoopAnalyticsClient extends AnalyticsClient {
  const NoopAnalyticsClient();

  @override
  Future<void> setUserId(String? userId) async {}

  @override
  Future<void> setUserProperties(Map<String, Object?> properties) async {}

  @override
  Future<void> track(AnalyticsEvent event) async {}
}

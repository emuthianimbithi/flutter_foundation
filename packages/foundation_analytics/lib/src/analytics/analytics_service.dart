import '../models/analytics_event.dart';
import 'analytics_client.dart';

class AnalyticsService {
  final AnalyticsClient _client;

  const AnalyticsService(this._client);

  Future<void> identify({String? userId, Map<String, Object?> properties = const {}}) async {
    await _client.setUserId(userId);
    if (properties.isNotEmpty) {
      await _client.setUserProperties(properties);
    }
  }

  Future<void> track(String name, {Map<String, Object?> params = const {}}) {
    return _client.track(AnalyticsEvent(name, params: params));
  }
}
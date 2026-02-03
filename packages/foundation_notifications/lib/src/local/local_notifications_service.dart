import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/notification_payload.dart';

/// Wraps flutter_local_notifications for foreground display and tap handling.
///
/// To wire taps back into your app, pass [onSelectPayload] when initializing.
class LocalNotificationsService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize({
    required Future<void> Function(String? payload) onSelectPayload,
  }) async {
    if (_initialized) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: android);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (resp) async {
        await onSelectPayload(resp.payload);
      },
    );

    _initialized = true;
  }

  Future<void> showForeground(NotificationPayload payload) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'foundation_default',
        'Notifications',
        channelDescription: 'Default notifications channel',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      payload.title ?? '',
      payload.body ?? '',
      details,
      payload: payload.toJsonString(),
    );
  }
}

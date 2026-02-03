import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';

import '../models/notification_payload.dart';

/// Handles FCM registration and message streams.
///
/// This class is intentionally thin and delegates routing to your [NotificationRouter].
class FcmService {
  final FirebaseMessaging _messaging;

  FcmService({FirebaseMessaging? messaging})
      : _messaging = messaging ?? FirebaseMessaging.instance;

  StreamSubscription<RemoteMessage>? _onMessageSub;
  StreamSubscription<RemoteMessage>? _onMessageOpenedAppSub;
  StreamSubscription<String>? _onTokenRefreshSub;

  /// Requests notification permissions through Firebase (iOS).
  Future<NotificationSettings> requestFirebasePermission() {
    return _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );
  }

  Future<String?> getToken() => _messaging.getToken();

  /// Subscribe to token refreshes.
  void listenForTokenRefresh(void Function(String token) onToken) {
    _onTokenRefreshSub?.cancel();
    _onTokenRefreshSub = _messaging.onTokenRefresh.listen(onToken);
  }

  /// Starts listening for foreground and tapped notifications.
  void startListeners({
    required void Function(NotificationPayload payload) onForeground,
    required void Function(NotificationPayload payload) onTap,
  }) {
    _onMessageSub?.cancel();
    _onMessageOpenedAppSub?.cancel();

    _onMessageSub = FirebaseMessaging.onMessage.listen((RemoteMessage msg) {
      final payload = NotificationPayload(
        title: msg.notification?.title,
        body: msg.notification?.body,
        data: msg.data,
      );
      onForeground(payload);
    });

    _onMessageOpenedAppSub =
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage msg) {
      final payload = NotificationPayload(
        title: msg.notification?.title,
        body: msg.notification?.body,
        data: msg.data,
      );
      onTap(payload);
    });
  }

  /// Handles the message that opened the app from a terminated state.
  Future<void> handleInitialMessage({
    required void Function(NotificationPayload payload) onTap,
  }) async {
    final msg = await _messaging.getInitialMessage();
    if (msg == null) return;
    final payload = NotificationPayload(
      title: msg.notification?.title,
      body: msg.notification?.body,
      data: msg.data,
    );
    onTap(payload);
  }

  Future<void> dispose() async {
    await _onMessageSub?.cancel();
    await _onMessageOpenedAppSub?.cancel();
    await _onTokenRefreshSub?.cancel();
  }
}

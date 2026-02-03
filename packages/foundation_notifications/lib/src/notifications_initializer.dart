import '../foundation_notifications.dart';

/// One-call bootstrap for notifications.
///
/// Typical flow:
/// - request permissions
/// - init local notifications
/// - start FCM listeners (foreground + tap + initial)
class NotificationsInitializer {
  final NotificationsPermissionService permissions;
  final LocalNotificationsService local;
  final FcmService fcm;
  final NotificationRouter router;

  NotificationsInitializer({
    required this.permissions,
    required this.local,
    required this.fcm,
    required this.router,
  });

  Future<void> initialize() async {
    // Request OS notification permission.
    await permissions.ensureGranted();

    // Request Firebase-specific permission (iOS; safe elsewhere).
    await fcm.requestFirebasePermission();

    // Initialize local notifications; map tap payload → router tap.
    await local.initialize(onSelectPayload: (payload) async {
      if (payload == null || payload.isEmpty) return;
      router.onTap(NotificationPayload.fromJsonString(payload));
    });

    // Foreground messages: show local notification + emit received.
    fcm.startListeners(
      onForeground: (payload) async {
        router.onForegroundMessage(payload);
        await local.showForeground(payload);
      },
      onTap: router.onTap,
    );

    await fcm.handleInitialMessage(onTap: router.onTap);
  }
}

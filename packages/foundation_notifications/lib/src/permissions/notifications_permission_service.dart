import 'package:permission_handler/permission_handler.dart';

/// Handles notification permission prompts (iOS + Android 13+).
class NotificationsPermissionService {
  const NotificationsPermissionService();

  Future<bool> ensureGranted() async {
    final status = await Permission.notification.status;
    if (status.isGranted) return true;

    final result = await Permission.notification.request();
    return result.isGranted;
  }

  Future<bool> isGranted() async => (await Permission.notification.status).isGranted;
}

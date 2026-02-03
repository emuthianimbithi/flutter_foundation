import 'package:permission_handler/permission_handler.dart';
import '../models/permission_state.dart';

class PermissionService {
  Future<PermissionState> request(Permission permission) async {
    final status = await permission.request();

    if (status.isGranted) {
      return const PermissionState(PermissionStatusState.granted);
    }
    if (status.isPermanentlyDenied) {
      return const PermissionState(PermissionStatusState.permanentlyDenied);
    }
    return const PermissionState(PermissionStatusState.denied);
  }

  Future<void> openSettings() async {
    await openAppSettings();
  }
}

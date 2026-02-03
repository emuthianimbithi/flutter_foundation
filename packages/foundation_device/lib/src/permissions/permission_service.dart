import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<PermissionStatus> request(Permission permission) async {
    return permission.request();
  }

  Future<bool> openSettings() => openAppSettings();

  Future<PermissionStatus> status(Permission permission) => permission.status;
}
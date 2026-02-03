import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../permissions/permission_service.dart';
import '../share/share_service.dart';
import '../device_info/device_info_service.dart';
import '../biometrics/biometric_service.dart';

final permissionServiceProvider =
    Provider<PermissionService>((ref) => PermissionService());
final shareServiceProvider = Provider<ShareService>((ref) => ShareService());
final deviceInfoServiceProvider =
    Provider<DeviceInfoService>((ref) => DeviceInfoService());
final biometricServiceProvider =
    Provider<BiometricService>((ref) => BiometricService());

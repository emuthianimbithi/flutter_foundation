import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service/permission_service.dart';

final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionService();
});

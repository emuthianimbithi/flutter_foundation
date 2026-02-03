import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_permissions/foundation_permissions.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsScreen extends ConsumerWidget {
  const PermissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const PermissionPage(
      permission: Permission.camera,
      title: 'Camera Permission',
      description: 'Request camera access using foundation_permissions service.',
    );
  }
}

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/permission_providers.dart';

class PermissionPage extends ConsumerWidget {
  final Permission permission;
  final String title;
  final String description;

  const PermissionPage({
    super.key,
    required this.permission,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(description),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await ref.read(permissionServiceProvider).request(permission);
              },
              child: const Text('Grant Permission'),
            ),
          ],
        ),
      ),
    );
  }
}

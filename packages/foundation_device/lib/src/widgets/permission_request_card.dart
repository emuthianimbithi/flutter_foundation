import 'package:flutter/material.dart';
import 'package:foundation_ui/foundation_ui.dart';
import 'package:permission_handler/permission_handler.dart';
import '../permissions/permission_service.dart';

class PermissionRequestCard extends StatelessWidget {
  final Permission permission;
  final String title;
  final String description;
  final PermissionService service;
  final VoidCallback? onGranted;

  const PermissionRequestCard({
    super.key,
    required this.permission,
    required this.title,
    required this.description,
    required this.service,
    this.onGranted,
  });

  @override
  Widget build(BuildContext context) {
    final t = FoundationTheme.typeOf(context);
    final tokens = FoundationTheme.tokensOf(context);

    return FoundationCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: t.bodyStrong),
          SizedBox(height: tokens.space8),
          Text(description, style: t.body),
          SizedBox(height: tokens.space16),
          FutureBuilder(
            future: service.status(permission),
            builder: (context, snapshot) {
              final status = snapshot.data;
              final isGranted = status?.isGranted ?? false;

              return Row(
                children: [
                  Expanded(
                    child: FoundationButton(
                      label: isGranted ? 'Granted' : 'Allow',
                      onPressed: isGranted
                          ? null
                          : () async {
                              final res = await service.request(permission);
                              if (res.isGranted) onGranted?.call();
                            },
                    ),
                  ),
                  SizedBox(width: tokens.space12),
                  FoundationButton(
                    label: 'Settings',
                    variant: FoundationButtonVariant.subtle,
                    onPressed: () => service.openSettings(),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

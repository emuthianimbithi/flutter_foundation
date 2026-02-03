import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_security/foundation_security.dart';
import 'package:foundation_ui/foundation_ui.dart';

class SecurityScreen extends ConsumerWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = FoundationTheme.tokensOf(context);
    final rootService = ref.read(rootDetectionServiceProvider);
    final screenshotService = ref.read(screenshotPreventionServiceProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Security')),
      body: Padding(
        padding: EdgeInsets.all(tokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<bool>(
              future: rootService.isDeviceCompromised(),
              builder: (_, snap) {
                final rooted = snap.data == true;
                return ListTile(
                  leading: Icon(rooted ? Icons.warning : Icons.verified, color: rooted ? Colors.orange : Colors.green),
                  title: Text(rooted ? 'Root detected' : 'Device not rooted'),
                );
              },
            ),
            SizedBox(height: tokens.space12),
            FoundationButton(
              label: 'Enable screenshot protection',
              onPressed: () => screenshotService.enable(),
              variant: FoundationButtonVariant.secondary,
            ),
            SizedBox(height: tokens.space8),
            const Text('Certificate pinning is provided via pinnedHttpClientProvider override.'),
          ],
        ),
      ),
    );
  }
}

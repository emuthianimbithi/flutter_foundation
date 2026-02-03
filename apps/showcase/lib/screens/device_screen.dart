import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_device/foundation_device.dart';
import 'package:foundation_ui/foundation_ui.dart';

class DeviceScreen extends ConsumerWidget {
  const DeviceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = FoundationTheme.tokensOf(context);
    final biometrics = ref.read(biometricServiceProvider);
    final deviceInfo = ref.read(deviceInfoServiceProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Device')),
      body: Padding(
        padding: EdgeInsets.all(tokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FoundationButton(
              label: 'Check biometrics',
              onPressed: () async {
                final available = await biometrics.canCheckBiometrics();
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Biometrics available: $available')));
              },
            ),
            SizedBox(height: tokens.space12),
            FoundationButton(
              label: 'Device info',
              variant: FoundationButtonVariant.secondary,
              onPressed: () async {
                final info = await deviceInfo.getDeviceSummary();
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(info.toString())));
              },
            ),
            SizedBox(height: tokens.space12),
            const Text('Scanner/Camera adapters live in foundation_device (placeholders in this demo).'),
          ],
        ),
      ),
    );
  }
}

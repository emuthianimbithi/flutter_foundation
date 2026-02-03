import 'package:flutter/material.dart';
import 'package:foundation_ui/foundation_ui.dart';

class QrScannerPlaceholder extends StatelessWidget {
  final VoidCallback? onTap;

  const QrScannerPlaceholder({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final tokens = FoundationTheme.tokensOf(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(tokens.radiusMd),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          border:
              Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.qr_code_scanner, size: 48),
              SizedBox(height: 8),
              Text('Scan QR Code'),
            ],
          ),
        ),
      ),
    );
  }
}

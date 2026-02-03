import 'package:flutter/material.dart';
import 'package:foundation_ui/foundation_ui.dart';

/// Vendor-neutral placeholder for audio playback.
///
/// In your app, implement a concrete widget using `just_audio` (recommended)
/// and keep the same interface.
class AudioPlayerPlaceholder extends StatelessWidget {
  final String sourceLabel;
  final VoidCallback? onTap;

  const AudioPlayerPlaceholder({super.key, required this.sourceLabel, this.onTap});

  @override
  Widget build(BuildContext context) {
    final tokens = FoundationTheme.tokensOf(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(tokens.radiusMd),
      child: Container(
        height: 72,
        padding: EdgeInsets.all(tokens.space16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            const Icon(Icons.audiotrack),
            SizedBox(width: tokens.space12),
            Expanded(child: Text(sourceLabel)),
            const Icon(Icons.play_arrow),
          ],
        ),
      ),
    );
  }
}
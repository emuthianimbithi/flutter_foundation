import 'package:flutter/material.dart';
import 'package:foundation_ui/foundation_ui.dart';

/// Vendor-neutral placeholder for video playback.
///
/// In your app, implement a concrete widget using `video_player` or `better_player`
/// and keep the same interface.
class VideoPlayerPlaceholder extends StatelessWidget {
  final String sourceLabel;
  final VoidCallback? onTap;

  const VideoPlayerPlaceholder(
      {super.key, required this.sourceLabel, this.onTap});

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
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.play_circle_outline, size: 48),
              const SizedBox(height: 8),
              Text(sourceLabel),
            ],
          ),
        ),
      ),
    );
  }
}

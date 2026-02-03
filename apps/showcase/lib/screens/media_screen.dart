import 'package:flutter/material.dart';
import 'package:foundation_media/foundation_media.dart';
import 'package:foundation_ui/foundation_ui.dart';

class MediaScreen extends StatelessWidget {
  const MediaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = FoundationTheme.tokensOf(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Media')),
      body: Padding(
        padding: EdgeInsets.all(tokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Image picker & player widgets'),
            SizedBox(height: tokens.space12),
            ImagePickerView(onPick: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pick image tapped')))),
            SizedBox(height: tokens.space12),
            const AudioPlayerPlaceholder(sourceLabel: 'demo_audio.mp3'),
            SizedBox(height: tokens.space12),
            const VideoPlayerPlaceholder(sourceLabel: 'demo_video.mp4'),
          ],
        ),
      ),
    );
  }
}

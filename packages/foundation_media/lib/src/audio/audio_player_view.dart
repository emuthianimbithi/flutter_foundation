import 'package:flutter/material.dart';

/// UI placeholder for audio playback.
/// Hook this to just_audio or another engine in your app.
class AudioPlayerView extends StatelessWidget {
  final String title;
  final VoidCallback onPlay;
  final VoidCallback onPause;

  const AudioPlayerView({
    super.key,
    required this.title,
    required this.onPlay,
    required this.onPause,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.music_note),
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(icon: const Icon(Icons.play_arrow), onPressed: onPlay),
          IconButton(icon: const Icon(Icons.pause), onPressed: onPause),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../models/chat_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = message.isMine
        ? theme.colorScheme.primary
        : theme.colorScheme.surfaceVariant;
    final fg = message.isMine
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurfaceVariant;

    return Align(
      alignment: message.isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(message.text, style: TextStyle(color: fg)),
      ),
    );
  }
}

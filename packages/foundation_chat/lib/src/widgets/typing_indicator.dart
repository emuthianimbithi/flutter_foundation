import 'package:flutter/material.dart';

class TypingIndicator extends StatelessWidget {
  final bool isTyping;

  const TypingIndicator({super.key, required this.isTyping});

  @override
  Widget build(BuildContext context) {
    if (!isTyping) return const SizedBox.shrink();
    return const Padding(
      padding: EdgeInsets.all(8),
      child: Text('Typing...', style: TextStyle(fontStyle: FontStyle.italic)),
    );
  }
}

import 'package:flutter/material.dart';

class ChatInput extends StatefulWidget {
  final ValueChanged<String> onSend;

  const ChatInput({super.key, required this.onSend});

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final controller = TextEditingController();

  void _send() {
    final text = controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Message'),
            onSubmitted: (_) => _send(),
          ),
        ),
        IconButton(icon: const Icon(Icons.send), onPressed: _send),
      ],
    );
  }
}

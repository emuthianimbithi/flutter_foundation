import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_chat/foundation_chat.dart';
import 'package:foundation_ui/foundation_ui.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = FoundationTheme.tokensOf(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          const Expanded(child: MessageList()),
          Padding(
            padding: EdgeInsets.all(tokens.space12),
            child: ChatInput(
              onSend: (text) {
                final current = ref.read(messagesProvider);
                final msg = ChatMessage(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  senderId: 'me',
                  text: text,
                  timestamp: DateTime.now(),
                  isMine: true,
                );
                ref.read(messagesProvider.notifier).state = [msg, ...current];
              },
            ),
          ),
        ],
      ),
    );
  }
}

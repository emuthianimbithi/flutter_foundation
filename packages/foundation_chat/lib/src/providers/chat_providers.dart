import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';

final messagesProvider = StateProvider<List<ChatMessage>>((ref) => []);

final typingUsersProvider = StateProvider<Set<String>>((ref) => {});
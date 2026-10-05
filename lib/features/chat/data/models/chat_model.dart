import 'package:cloud_firestore/cloud_firestore.dart';

// chats/{chatId}
class ChatModel {
  final String chatID;
  final List<String> participants;
  final String lastMessage;
  final Timestamp? lastMessageAt;
  final String lastSenderID;
  final List<String> lastMessageReadBy;
  final Map<String, int> unreadMessagesCount;

  ChatModel({
    required this.chatID,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.lastSenderID,
    required this.lastMessageReadBy,
    required this.unreadMessagesCount,
  });
}

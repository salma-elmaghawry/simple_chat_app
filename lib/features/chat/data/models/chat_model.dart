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

  factory ChatModel.fromJson(Map<String, dynamic> json, String id) {
    return ChatModel(
      chatID: id,
      participants: List<String>.from(json['participants'] ?? []),
      lastMessage: json['lastMessage'] as String? ?? '',
      lastMessageAt: json['lastMessageAt'] as Timestamp?,
      lastSenderID: json['lastSenderId'] as String? ?? '',
      lastMessageReadBy: List<String>.from(json['lastMessageReadBy'] ?? []),
      unreadMessagesCount: Map<String, int>.from(json['unreadCount'] ?? {}),
    );
  }

  // Same id for both users: "uidA_uidB" (sorted), so no duplicate chats.
  static String chatIdFor(String uid1, String uid2) {
    final ids = [uid1, uid2]..sort();
    return ids.join('_');
  }

  // The uid of the other person in this chat.
  String otherUserId(String myId) =>
      participants.firstWhere((id) => id != myId);
}

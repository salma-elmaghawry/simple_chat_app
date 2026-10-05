import 'package:cloud_firestore/cloud_firestore.dart';

// chats/{chatId}/messages/{messageId}
class MessageModel {
  final String messageID;
  final String senderID;
  final String receiverID;
  final String message;
  final Timestamp? createdAt;
  final String messageType;
  final String status;
  final List<String> readBy;

  MessageModel({
    required this.messageID,
    required this.senderID,
    required this.receiverID,
    required this.message,
    required this.createdAt,
    required this.messageType,
    required this.status,
    required this.readBy,
  });
}

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

  // createdAt is null for a moment right after sending,
  // until the server writes its time.
  factory MessageModel.fromJson(Map<String, dynamic> json, String id) {
    return MessageModel(
      messageID: id,
      senderID: json['senderId'] as String,
      receiverID: json['receiverId'] as String,
      message: json['message'] as String,
      createdAt: json['createdAt'] as Timestamp?,
      messageType: json['type'] as String? ?? 'text',
      status: json['status'] as String? ?? 'sent',
      readBy: List<String>.from(json['readBy'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderID,
      'receiverId': receiverID,
      'message': message,
      // The server sets the time, not the phone.
      'createdAt': FieldValue.serverTimestamp(),
      'type': messageType,
      'status': status,
      'readBy': readBy,
    };
  }
}

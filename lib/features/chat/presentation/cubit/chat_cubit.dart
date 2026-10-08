import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_chat_app/features/auth/data/models/user_model.dart';
import 'package:simple_chat_app/features/chat/data/models/chat_model.dart';
import 'package:simple_chat_app/features/chat/data/models/message_model.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit({required this.otherUser})
    : myId = FirebaseAuth.instance.currentUser!.uid,
      super(ChatInitial());

  final UserModel otherUser;
  final String myId;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  StreamSubscription? messagesSubscription;

  String get chatId => ChatModel.chatIdFor(myId, otherUser.uid);

  CollectionReference<Map<String, dynamic>> get messagesRef =>
      firestore.collection('chats').doc(chatId).collection('messages');

  //<< -- listen to messages in real time -- >>
  void listenToMessages() {
    emit(ChatLoading());

    // snapshots() is a Stream: it fires again on every new or changed message.
    messagesSubscription = messagesRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            final messages = snapshot.docs
                .map((doc) => MessageModel.fromJson(doc.data(), doc.id))
                .toList();

            emit(ChatSuccess(messages: messages));
            markAsRead(messages);
          },
          onError: (error) => emit(ChatFailure(message: error.toString())),
        );
  }

  //<< -- send a message -- >>
  Future<void> sendMessage(String text) async {
    final message = text.trim();
    if (message.isEmpty) return;

    final chatRef = firestore.collection('chats').doc(chatId);
    // doc() with no id: Firestore makes a new id for us.
    final messageRef = messagesRef.doc();

    final newMessage = MessageModel(
      messageID: messageRef.id,
      senderID: myId,
      receiverID: otherUser.uid,
      message: message,
      createdAt: null,
      messageType: 'text',
      status: 'sent',
      readBy: [myId],
    );

    // Both writes succeed together or fail together.
    final batch = firestore.batch();

    batch.set(messageRef, newMessage.toJson());

    // merge: creates the chat the first time, updates it after that.
    // increment runs on the server, so two messages at once both count.
    batch.set(chatRef, {
      'participants': [myId, otherUser.uid],
      'lastMessage': message,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'lastSenderId': myId,
      'lastMessageReadBy': [myId],
      'unreadCount': {otherUser.uid: FieldValue.increment(1)},
    }, SetOptions(merge: true));

    try {
      await batch.commit();
    } on FirebaseException catch (e) {
      emit(ChatSendFailure(message: e.message ?? 'Message not sent'));
    }
  }

  //<< -- mark the other user's messages as read -- >>
  Future<void> markAsRead(List<MessageModel> messages) async {
    final unread = messages
        .where((m) => m.senderID != myId && !m.readBy.contains(myId))
        .toList();

    // Nothing new: stop here, or this write would trigger the stream again.
    if (unread.isEmpty) return;

    final batch = firestore.batch();

    for (final message in unread) {
      batch.update(messagesRef.doc(message.messageID), {
        'readBy': FieldValue.arrayUnion([myId]),
      });
    }

    batch.set(firestore.collection('chats').doc(chatId), {
      'unreadCount': {myId: 0},
      'lastMessageReadBy': FieldValue.arrayUnion([myId]),
    }, SetOptions(merge: true));

    try {
      await batch.commit();
    } on FirebaseException catch (_) {
      // Not critical: the next snapshot tries again.
    }
  }

  // Stop listening when the screen closes, or the stream keeps running.
  @override
  Future<void> close() {
    messagesSubscription?.cancel();
    return super.close();
  }
}

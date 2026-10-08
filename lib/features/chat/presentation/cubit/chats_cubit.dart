import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_chat_app/features/auth/data/models/user_model.dart';
import 'package:simple_chat_app/features/chat/data/models/chat_model.dart';

part 'chats_state.dart';

class ChatsCubit extends Cubit<ChatsState> {
  ChatsCubit()
    : myId = FirebaseAuth.instance.currentUser!.uid,
      super(ChatsInitial());

  final String myId;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  StreamSubscription? chatsSubscription;

  // Users we already loaded, so each update doesn't fetch them again.
  final Map<String, UserModel> usersCache = {};

  //<< -- listen to my chats, newest first -- >>
  // Needs a composite index (participants + lastMessageAt),
  // see firestore.indexes.json.
  void listenToChats() {
    emit(ChatsLoading());

    chatsSubscription = firestore
        .collection('chats')
        .where('participants', arrayContains: myId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) async {
            final chats = snapshot.docs
                .map((doc) => ChatModel.fromJson(doc.data(), doc.id))
                .toList();

            if (chats.isEmpty) {
              emit(ChatsEmpty());
              return;
            }

            // Fetch only the users we don't have yet, all at the same time.
            final missingIds = chats
                .map((chat) => chat.otherUserId(myId))
                .where((id) => !usersCache.containsKey(id))
                .toSet();

            await Future.wait(
              missingIds.map((id) async {
                final doc = await firestore.collection('users').doc(id).get();
                if (doc.exists) {
                  usersCache[id] = UserModel.fromJson({
                    ...doc.data()!,
                    'uid': doc.id,
                  });
                }
              }),
            );

            // The cubit may have closed while we were waiting.
            if (isClosed) return;

            emit(
              ChatsSuccess(chats: chats, users: Map.unmodifiable(usersCache)),
            );
          },
          onError: (error) => emit(ChatsFailure(message: error.toString())),
        );
  }

  @override
  Future<void> close() {
    chatsSubscription?.cancel();
    return super.close();
  }
}

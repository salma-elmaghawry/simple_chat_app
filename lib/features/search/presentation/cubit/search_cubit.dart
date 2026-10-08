import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_chat_app/features/auth/data/models/user_model.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(SearchInitial());

  // All users loaded so far for the current search.
  final List<UserModel> users = [];

  // Last document of the previous page, the cursor for the next page.
  DocumentSnapshot<Map<String, dynamic>>? lastDocument;

  String currentSearchText = '';

  bool hasMore = true;
  bool isLoadingMore = false;

  // Each new search gets a new id, so an old slow request can't
  // override the results of a newer one.
  int searchRequestId = 0;
  static const int pageSize = 10;

  //<< -- start a new search -- >>
  Future<void> searchUsers({required String value}) async {
    final searchText = value.trim().toLowerCase();
    final requestID = ++searchRequestId; 
    if (searchText.isEmpty) {
      currentSearchText = "";
      users.clear();
      lastDocument = null;
      hasMore = false;
      isLoadingMore = false;
      emit(SearchInitial());
      return;
    }
    currentSearchText = searchText;
    users.clear();
    lastDocument = null;
    hasMore = true;
    isLoadingMore = false;
    emit(SearchLoading());
    try {
      // Prefix search: every searchName between "text" and "text\uf8ff".
      final snapshot = await FirebaseFirestore.instance
          .collection("users")
          .orderBy('searchName')
          .startAt([searchText])
          .endAt(['$searchText\uf8ff'])
          .limit(pageSize)
          .get();

      if (requestID != searchRequestId) return;
      if (snapshot.docs.isNotEmpty) {
        lastDocument = snapshot.docs.last;
      }
      hasMore = snapshot.docs.length == pageSize;

      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      final firstPageUsers = snapshot.docs
      //if you search for users, you don't want to include yourself in the results
          .where((document) => document.id != currentUserId)
          .map(
            (document) =>
                UserModel.fromJson({...document.data(), 'uid': document.id}),
          )
          .toList();

      users.addAll(firstPageUsers);

      if (users.isEmpty) {
        emit(SearchEmpty());
        return;
      }
      emit(
        SearchSuccess(
          users: List.unmodifiable(users),
          hasMore: hasMore,
          isLoadingMore: false,
        ),
      );
    } on FirebaseException catch (e) {
      if (requestID != searchRequestId) return;
      emit(SearchFailure(message: e.message ?? 'An error occurred'));
    } catch (e) {
      if (requestID != searchRequestId) return;
      emit(SearchFailure(message: e.toString()));
    }
  }

  //<< -- load the next page of the current search -- >>
  Future<void> loadMoreUsers() async {
    if (isLoadingMore ||
        !hasMore ||
        lastDocument == null ||
        currentSearchText.isEmpty) {
      return;
    }

    isLoadingMore = true;

    final requestId = searchRequestId;
    final searchText = currentSearchText;
    emit(
      SearchSuccess(
        users: List.unmodifiable(users),
        hasMore: hasMore,
        isLoadingMore: true,
      ),
    );

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .orderBy('searchName')
          .startAfterDocument(lastDocument!)
          .endAt(['$searchText\uf8ff'])
          .limit(pageSize)
          .get();

      // A new search started while this page was loading.
      if (requestId != searchRequestId) return;

      if (snapshot.docs.isNotEmpty) {
        lastDocument = snapshot.docs.last;
      }

      hasMore = snapshot.docs.length == pageSize;

      final currentUserId = FirebaseAuth.instance.currentUser?.uid;

      final newUsers = snapshot.docs
          .where((document) => document.id != currentUserId)
          .map(
            (document) =>
                UserModel.fromJson({...document.data(), 'uid': document.id}),
          )
          .toList();

      // Skip users we already have, in case the data changed between pages.
      final existingIds = users.map((user) => user.uid).toSet();

      users.addAll(newUsers.where((user) => existingIds.add(user.uid)));

      isLoadingMore = false;

      emit(
        SearchSuccess(
          users: List.unmodifiable(users),
          hasMore: hasMore,
          isLoadingMore: false,
        ),
      );
    } catch (error) {
      if (requestId != searchRequestId) return;

      isLoadingMore = false;

      // Keep the old results instead of hiding them.
      emit(
        SearchSuccess(
          users: List.unmodifiable(users),
          hasMore: hasMore,
          isLoadingMore: false,
        ),
      );
    }
  }
}

part of 'chats_cubit.dart';

@immutable
sealed class ChatsState {}

final class ChatsInitial extends ChatsState {}

final class ChatsLoading extends ChatsState {}

final class ChatsEmpty extends ChatsState {}

final class ChatsSuccess extends ChatsState {
  final List<ChatModel> chats;
  // The other person of each chat, by uid.
  final Map<String, UserModel> users;

  ChatsSuccess({required this.chats, required this.users});
}

final class ChatsFailure extends ChatsState {
  final String message;

  ChatsFailure({required this.message});
}

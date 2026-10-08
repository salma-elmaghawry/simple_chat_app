part of 'chat_cubit.dart';

@immutable
sealed class ChatState {}

final class ChatInitial extends ChatState {}

final class ChatLoading extends ChatState {}

final class ChatSuccess extends ChatState {
  final List<MessageModel> messages;

  ChatSuccess({required this.messages});
}

final class ChatFailure extends ChatState {
  final String message;

  ChatFailure({required this.message});
}

// Sending failed: show a SnackBar, keep the messages on screen.
final class ChatSendFailure extends ChatState {
  final String message;

  ChatSendFailure({required this.message});
}

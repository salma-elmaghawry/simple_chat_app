import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:simple_chat_app/core/helpers/extensions.dart';
import 'package:simple_chat_app/features/auth/data/models/user_model.dart';
import 'package:simple_chat_app/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:simple_chat_app/features/chat/presentation/widgets/chat_app_bar.dart';
import 'package:simple_chat_app/features/chat/presentation/widgets/message_bubble.dart';
import 'package:simple_chat_app/features/chat/presentation/widgets/message_input.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key, required this.otherUser});

  final UserModel otherUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ChatAppBar(user: otherUser),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ChatCubit, ChatState>(
              listenWhen: (_, current) => current is ChatSendFailure,
              listener: (context, state) => context.showSnackBar(
                (state as ChatSendFailure).message,
                isError: true,
              ),
              buildWhen: (_, current) => current is! ChatSendFailure,
              builder: (context, state) {
                final myId = context.read<ChatCubit>().myId;

                return switch (state) {
                  ChatInitial() || ChatLoading() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  ChatFailure(:final message) => Center(
                    child: Text(message, textAlign: TextAlign.center),
                  ),
                  ChatSuccess(:final messages) when messages.isEmpty =>
                    const Center(child: Text('Say hi 👋')),
                  ChatSuccess(:final messages) => ListView.builder(
                    // Newest message at the bottom, next to the input.
                    reverse: true,
                    padding: EdgeInsets.all(16.w),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return MessageBubble(
                        message: message,
                        isMe: message.senderID == myId,
                        isRead: message.readBy.contains(otherUser.uid),
                      );
                    },
                  ),
                  ChatSendFailure() => const SizedBox.shrink(),
                };
              },
            ),
          ),
          MessageInput(
            onSend: (text) => context.read<ChatCubit>().sendMessage(text),
          ),
        ],
      ),
    );
  }
}

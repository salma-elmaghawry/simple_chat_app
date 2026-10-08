import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_chat_app/features/chat/presentation/cubit/chats_cubit.dart';
import 'package:simple_chat_app/features/chat/presentation/widgets/chat_list_item.dart';

// ChatsCubit is provided in HomeScreen, so the stream survives tab switches.
class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatsCubit, ChatsState>(
      builder: (context, state) {
        final myId = context.read<ChatsCubit>().myId;

        return switch (state) {
          ChatsInitial() ||
          ChatsLoading() => const Center(child: CircularProgressIndicator()),
          ChatsEmpty() => const Center(
            child: Text('No chats yet, search for someone to talk to'),
          ),
          ChatsFailure(:final message) => Center(
            child: Text(message, textAlign: TextAlign.center),
          ),
          ChatsSuccess(:final chats, :final users) => ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final user = users[chat.otherUserId(myId)];
              if (user == null) return const SizedBox.shrink();
              return ChatListItem(chat: chat, user: user, myId: myId);
            },
          ),
        };
      },
    );
  }
}

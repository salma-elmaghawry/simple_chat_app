import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:simple_chat_app/core/helpers/date_formatter.dart';
import 'package:simple_chat_app/core/helpers/extensions.dart';
import 'package:simple_chat_app/core/helpers/spacing.dart';
import 'package:simple_chat_app/core/routes/routes.dart';
import 'package:simple_chat_app/core/utils/app_text_styles.dart';
import 'package:simple_chat_app/core/widgets/user_avatar.dart';
import 'package:simple_chat_app/features/auth/data/models/user_model.dart';
import 'package:simple_chat_app/features/chat/data/models/chat_model.dart';

class ChatListItem extends StatelessWidget {
  const ChatListItem({
    super.key,
    required this.chat,
    required this.user,
    required this.myId,
  });

  final ChatModel chat;
  final UserModel user;
  final String myId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMyLastMessage = chat.lastSenderID == myId;
    final seen = chat.lastMessageReadBy.contains(user.uid);
    final unread = chat.unreadMessagesCount[myId] ?? 0;

    return GestureDetector(
      onTap: () => context.pushNamed(Routes.chat, arguments: user),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: theme.colorScheme.primary, width: 1.5),
        ),
        child: Row(
          children: [
            UserAvatar(user: user, radius: 22),
            horizontalSpace(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.font14Normal,
                  ),
                  verticalSpace(2),
                  Row(
                    children: [
                      // I sent the last message: filled = they read it.
                      if (isMyLastMessage) ...[
                        Icon(
                          seen
                              ? Icons.check_circle
                              : Icons.check_circle_outline,
                          size: 14.sp,
                          color: Colors.green,
                        ),
                        horizontalSpace(4),
                      ],
                      Expanded(
                        child: Text(
                          chat.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.font11Normal.copyWith(
                            fontWeight: unread > 0 ? FontWeight.w600 : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            horizontalSpace(8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatTime(chat.lastMessageAt),
                  style: AppTextStyles.font11Normal,
                ),
                if (unread > 0) ...[
                  verticalSpace(4),
                  CircleAvatar(
                    radius: 9.r,
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      '$unread',
                      style: TextStyle(color: Colors.white, fontSize: 10.sp),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

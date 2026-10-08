import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:simple_chat_app/core/helpers/date_formatter.dart';
import 'package:simple_chat_app/core/helpers/spacing.dart';
import 'package:simple_chat_app/core/utils/app_text_styles.dart';
import 'package:simple_chat_app/features/chat/data/models/message_model.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.isRead,
  });

  final MessageModel message;
  final bool isMe;
  final bool isRead;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final textColor = isMe ? Colors.white : theme.colorScheme.onSurface;

    // My messages: right + filled purple. Theirs: left + purple border.
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: 0.7.sw),
        margin: EdgeInsets.symmetric(vertical: 4.h),
        padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 6.h),
        decoration: BoxDecoration(
          color: isMe ? primary : theme.colorScheme.surface,
          border: isMe ? null : Border.all(color: primary, width: 1.5),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.message,
              style: AppTextStyles.font11Normal.copyWith(color: textColor),
            ),
            verticalSpace(4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formatTime(message.createdAt),
                  style: TextStyle(fontSize: 8.sp, color: textColor),
                ),
                // Ticks only on my messages: ✓ sent, ✓✓ read.
                if (isMe) ...[
                  horizontalSpace(4),
                  Icon(
                    isRead ? Icons.done_all : Icons.done,
                    size: 12.sp,
                    color: isRead ? Colors.greenAccent : Colors.white70,
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

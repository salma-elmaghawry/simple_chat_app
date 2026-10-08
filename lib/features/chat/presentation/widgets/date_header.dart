import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:simple_chat_app/core/utils/app_text_styles.dart';

// Small chip between messages of different days: "Today", "Yesterday"...
class DateHeader extends StatelessWidget {
  const DateHeader({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          label,
          style: AppTextStyles.font11Normal.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

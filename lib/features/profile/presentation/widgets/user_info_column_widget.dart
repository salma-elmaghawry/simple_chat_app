import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:simple_chat_app/core/helpers/spacing.dart';

class UserInfoColumnWidget extends StatelessWidget {
  const UserInfoColumnWidget({
    super.key,
    required this.name,
    required this.email,
  });

  final String name;
  final String email;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          width: 180.w,
          padding: EdgeInsets.all(8.r),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.primary, width: 2),
            borderRadius: BorderRadius.circular(13.r),
          ),
          child: Text(
            name,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        verticalSpace(17),
        SizedBox(
          width: 180.w,
          child: Text(
            email,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

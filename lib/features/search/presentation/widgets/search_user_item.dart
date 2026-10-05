import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:simple_chat_app/core/helpers/spacing.dart';
import 'package:simple_chat_app/features/auth/data/models/user_model.dart';

class SearchUserItem extends StatelessWidget {
  const SearchUserItem({super.key, required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String? image = user.image;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          // No photo: show the first letter of the name instead.
          CircleAvatar(
            radius: 20.r,
            backgroundColor: theme.colorScheme.primary,
            backgroundImage: image == null ? null : NetworkImage(image),
            child: image == null
                ? Text(
                    user.name.isEmpty ? '?' : user.name[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  )
                : null,
          ),
          horizontalSpace(16),
          Expanded(
            child: Text(
              user.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}

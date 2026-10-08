import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:simple_chat_app/features/auth/data/models/user_model.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.user, this.radius = 20});

  final UserModel user;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final String? image = user.image;

    // No photo: show the first letter of the name instead.
    return CircleAvatar(
      radius: radius.r,
      backgroundColor: Theme.of(context).colorScheme.primary,
      backgroundImage: image == null ? null : NetworkImage(image),
      child: image == null
          ? Text(
              user.name.isEmpty ? '?' : user.name[0].toUpperCase(),
              style: const TextStyle(color: Colors.white),
            )
          : null,
    );
  }
}

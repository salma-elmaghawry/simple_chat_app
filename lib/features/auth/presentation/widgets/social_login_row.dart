import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:simple_chat_app/core/helpers/spacing.dart';
import 'package:simple_chat_app/core/utils/app_assets.dart';

class SocialLoginRow extends StatelessWidget {
  const SocialLoginRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(AppAssets.facebook, width: 44.w),
        horizontalSpace(19.5),
        Image.asset(AppAssets.google, width: 35.w),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ContainerSettingOptionWidget extends StatelessWidget {
  const ContainerSettingOptionWidget({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
  });

  final String text;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 13.w),
        width: double.infinity,
        height: 58.h,
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.primary, width: 2),
          borderRadius: BorderRadius.circular(13.r),
        ),
        child: Row(
          children: [
            Text(text, style: theme.textTheme.bodyLarge),
            const Spacer(),
            Icon(icon, color: theme.colorScheme.primary, size: 26.r),
          ],
        ),
      ),
    );
  }
}

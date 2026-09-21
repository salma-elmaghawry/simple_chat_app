import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrDivider extends StatelessWidget {
  final String label;

  const OrDivider({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final line = Expanded(
      child: Container(height: 1, color: theme.colorScheme.primary),
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 33.w),
      child: Row(
        children: [
          line,
          Text(label, style: theme.textTheme.bodyLarge),
          line,
        ],
      ),
    );
  }
}

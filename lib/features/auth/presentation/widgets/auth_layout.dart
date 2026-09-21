import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:simple_chat_app/core/helpers/spacing.dart';
import 'package:simple_chat_app/core/utils/app_assets.dart';

class AuthLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final double illustrationTop;
  final double headerGap;
  final List<Widget> children;

  const AuthLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.illustrationTop,
    required this.headerGap,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Stack(
            children: [
              PositionedDirectional(
                top: illustrationTop.h,
                end: 7.w,
                child: Image.asset(
                  AppAssets.avatar,
                  width: 100.w,
                  matchTextDirection: true,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    verticalSpace(46),
                    Text(title, style: textTheme.headlineMedium),
                    verticalSpace(7),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 272.w),
                      child: Text(subtitle, style: textTheme.bodyLarge),
                    ),
                    verticalSpace(headerGap),
                    ...children,
                    verticalSpace(24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

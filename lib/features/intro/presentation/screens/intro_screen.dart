import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:simple_chat_app/core/helpers/extensions.dart';
import 'package:simple_chat_app/core/helpers/spacing.dart';
import 'package:simple_chat_app/core/routes/routes.dart';
import 'package:simple_chat_app/core/utils/app_assets.dart';
import 'package:simple_chat_app/core/widgets/primary_button.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsetsDirectional.symmetric(horizontal: 33.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  verticalSpace(25),
                  Padding(
                    padding: EdgeInsetsDirectional.only(start: 17.3.w),
                    child: Text(
                      'Get Closer To EveryOne',
                      style: textTheme.headlineLarge,
                    ),
                  ),
                  verticalSpace(30),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 280.w),
                    child: Text(
                      'Helps you to contact everyone with just easy way',
                      style: textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: 60.h),
                child: Center(
                  child: Image.asset(AppAssets.intro, width: 350.w),
                ),
              ),
            ),
            PrimaryButton(
              label: 'Get Started',
              textStyle: textTheme.headlineMedium,
              onPressed: () => context.pushReplacementNamed(Routes.login),
            ),
            verticalSpace(97),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:simple_chat_app/core/helpers/extensions.dart';
import 'package:simple_chat_app/core/helpers/spacing.dart';
import 'package:simple_chat_app/core/routes/routes.dart';
import 'package:simple_chat_app/core/widgets/primary_button.dart';
import 'package:simple_chat_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:simple_chat_app/features/auth/presentation/widgets/auth_switch_prompt.dart';

/// Shown after sign-up, until the user opens the link Firebase emailed them.
class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  void _onAuthState(BuildContext context, AuthState state) {
    switch (state) {
      case AuthEmailVerified():
        context.showSnackBar('Email verified. Please log in.');
        context.pushNamedAndRemoveUntil(Routes.login, predicate: (_) => false);
      case AuthVerificationEmailSent(:final email):
        context.showSnackBar('Verification email sent to $email.');
      case AuthError(:final message):
        context.showSnackBar(message, isError: true);
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final email = context.read<AuthCubit>().currentUser?.email;

    return BlocListener<AuthCubit, AuthState>(
      listener: _onAuthState,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Check Your Email',
                  style: textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                verticalSpace(12),
                Text(
                  email == null
                      ? "We've sent a verification link to your email address."
                      : "We've sent a verification link to $email.",
                  style: textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                verticalSpace(4),
                Text(
                  'Please verify your email before logging in.',
                  style: textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                verticalSpace(40),
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) => PrimaryButton(
                    label: "I've Verified My Email",
                    isLoading: state is AuthLoading,
                    onPressed: () =>
                        context.read<AuthCubit>().checkEmailVerified(),
                  ),
                ),
                verticalSpace(24),
                AuthSwitchPrompt(
                  prompt: "Didn't get the email?",
                  actionLabel: 'Resend Email',
                  onAction: () =>
                      context.read<AuthCubit>().sendEmailVerification(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

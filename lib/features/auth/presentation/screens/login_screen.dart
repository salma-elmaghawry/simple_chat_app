import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:simple_chat_app/core/helpers/app_validators.dart';
import 'package:simple_chat_app/core/helpers/extensions.dart';
import 'package:simple_chat_app/core/routes/routes.dart';
import 'package:simple_chat_app/core/widgets/primary_button.dart';
import 'package:simple_chat_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:simple_chat_app/features/auth/presentation/widgets/auth_layout.dart';
import 'package:simple_chat_app/features/auth/presentation/widgets/auth_switch_prompt.dart';
import 'package:simple_chat_app/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:simple_chat_app/features/auth/presentation/widgets/or_divider.dart';
import 'package:simple_chat_app/features/auth/presentation/widgets/social_login_row.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<AuthCubit>().loginWithEmailAndPassword(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  // Forget password uses the email typed in the email field.
  void _forgotPassword() {
    final emailError = AppValidators.validateEmail(_emailController.text);
    if (emailError != null) {
      context.showSnackBar(
        'Write your email first, then tap Forgot Password.',
        isError: true,
      );
      return;
    }
    FocusScope.of(context).unfocus();
    context.read<AuthCubit>().resetPassword(email: _emailController.text);
  }

  void _onAuthState(BuildContext context, AuthState state) {
    if (state is AuthSuccess) {
      context.pushNamedAndRemoveUntil(Routes.home, predicate: (_) => false);
    } else if (state is AuthEmailNotVerified) {
      context.showSnackBar(
        'Please verify your email first, check your inbox.',
        isError: true,
      );
    } else if (state is AuthPasswordResetSent) {
      context.showSnackBar('Password reset link sent, check your email.');
    } else if (state is AuthError) {
      context.showSnackBar(state.message, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<AuthCubit, AuthState>(
      listener: _onAuthState,
      builder: (context, state) => ModalProgressHUD(
        inAsyncCall: state is AuthLoading,
        child: Form(
          key: _formKey,
          child: AuthLayout(
            title: 'Hello, Welcome Back',
            subtitle:
                'Happy to see you again, to use your account please login first.',
            illustrationTop: 39,
            headerGap: 55,
            children: [
              AuthTextField(
                label: 'Email Address',
                controller: _emailController,
                validator: AppValidators.validateEmail,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              Padding(
                padding: EdgeInsets.only(top: 40.h),
                child: AuthTextField(
                  label: 'Password',
                  controller: _passwordController,
                  validator: AppValidators.validatePassword,
                  textInputAction: TextInputAction.done,
                  isPassword: true,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 23.2.h),
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _forgotPassword,
                    child: Text(
                      'Forgot Password',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 45.8.h),
                child: PrimaryButton(label: 'Login', onPressed: _submit),
              ),
              Padding(
                padding: EdgeInsets.only(top: 30.7.h),
                child: OrDivider(label: 'Or Login with'),
              ),
              Padding(
                padding: EdgeInsets.only(top: 13.3.h),
                child: SocialLoginRow(
                  onGoogleTap: () =>
                      context.read<AuthCubit>().loginWithGoogle(),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 28.h),
                child: AuthSwitchPrompt(
                  prompt: "Don't have an account?",
                  actionLabel: 'Sign Up',
                  onAction: () => context.pushReplacementNamed(Routes.signUp),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

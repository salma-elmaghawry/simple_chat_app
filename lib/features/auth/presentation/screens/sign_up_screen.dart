import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:simple_chat_app/core/helpers/app_validators.dart';
import 'package:simple_chat_app/core/helpers/extensions.dart';
import 'package:simple_chat_app/core/routes/routes.dart';
import 'package:simple_chat_app/core/widgets/primary_button.dart';
import 'package:simple_chat_app/features/auth/presentation/widgets/auth_layout.dart';
import 'package:simple_chat_app/features/auth/presentation/widgets/auth_switch_prompt.dart';
import 'package:simple_chat_app/features/auth/presentation/widgets/auth_text_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: AuthLayout(
        title: 'Hello, Let’s Get Started',
        subtitle: 'Create your account and join us today.',
        illustrationTop: 23,
        headerGap: 55,
        children: [
          AuthTextField(
            label: 'Full Name',
            controller: _nameController,
            validator: AppValidators.validateName,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
          ),
          Padding(
            padding: EdgeInsets.only(top: 40.h),
            child: AuthTextField(
              label: 'Email Address',
              controller: _emailController,
              validator: AppValidators.validateEmail,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
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
            padding: EdgeInsets.only(top: 46.h),
            child: PrimaryButton(
              label: 'Sign Up',
              onPressed: _submit,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 31.h),
            child: AuthSwitchPrompt(
              prompt: 'Already have an account?',
              actionLabel: 'Login',
              onAction: () => context.pushReplacementNamed(Routes.login),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_chat_app/core/helpers/extensions.dart';
import 'package:simple_chat_app/core/helpers/spacing.dart';
import 'package:simple_chat_app/core/routes/routes.dart';
import 'package:simple_chat_app/core/widgets/primary_button.dart';
import 'package:simple_chat_app/features/auth/presentation/cubit/auth_cubit.dart';

/// Placeholder landing screen for signed-in users. Replace with the chat list.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final user = context.read<AuthCubit>().currentUser;
    final name = user?.displayName?.trim();
    final greeting = (name != null && name.isNotEmpty)
        ? 'Welcome, $name'
        : 'Welcome';

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthLoggedOut) {
          context.pushNamedAndRemoveUntil(
            Routes.login,
            predicate: (_) => false,
          );
        } else if (state is AuthError) {
          context.showSnackBar(state.message, isError: true);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(greeting, style: textTheme.headlineMedium),
                if (user?.email != null) ...[
                  verticalSpace(8),
                  Text(user!.email!, style: textTheme.bodyLarge),
                ],
                verticalSpace(40),
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) => PrimaryButton(
                    label: 'Logout',
                    isLoading: state is AuthLoading,
                    onPressed: () => context.read<AuthCubit>().logout(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

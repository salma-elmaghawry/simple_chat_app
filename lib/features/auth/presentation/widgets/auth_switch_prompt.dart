import 'package:flutter/material.dart';

class AuthSwitchPrompt extends StatelessWidget {
  final String prompt;
  final String actionLabel;
  final VoidCallback onAction;

  const AuthSwitchPrompt({
    super.key,
    required this.prompt,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 4,
        children: [
          Text(prompt, style: theme.textTheme.bodyLarge),
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

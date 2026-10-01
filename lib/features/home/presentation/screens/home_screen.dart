import 'package:flutter/material.dart';
import 'package:simple_chat_app/core/helpers/spacing.dart';
import 'package:simple_chat_app/features/profile/presentation/screens/profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          title: Text('Easy Chat', style: theme.textTheme.headlineMedium),
        ),
        body: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: TabBar(
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                splashFactory: NoSplash.splashFactory,
                labelColor: theme.colorScheme.primary,
                labelStyle: theme.textTheme.titleLarge,
                unselectedLabelStyle: theme.textTheme.bodyLarge,
                indicatorColor: theme.colorScheme.primary,
                indicatorWeight: 2,
                indicatorSize: TabBarIndicatorSize.label,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Chats'),
                  Tab(text: 'Search'),
                  Tab(text: 'Profile'),
                ],
              ),
            ),
            verticalSpace(20),
            const Expanded(
              child: TabBarView(
                children: [
                  // Chats and Search come in the next sessions.
                  Center(child: Text('Chats')),
                  Center(child: Text('Search')),
                  ProfileScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

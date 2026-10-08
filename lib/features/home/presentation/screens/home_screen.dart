import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_chat_app/core/helpers/spacing.dart';
import 'package:simple_chat_app/features/chat/presentation/cubit/chats_cubit.dart';
import 'package:simple_chat_app/features/chat/presentation/screens/chats_screen.dart';
import 'package:simple_chat_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:simple_chat_app/features/search/presentation/screens/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// WidgetsBindingObserver tells us when the app goes to the background
// or comes back, so we can update isOnline.
class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setOnline(true);
  }

  // resumed = app on screen, anything else = in the background.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setOnline(state == AppLifecycleState.resumed);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void setOnline(bool isOnline) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    FirebaseFirestore.instance.collection('users').doc(uid).update({
      'isOnline': isOnline,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Above the tabs, so the chats stream isn't restarted on every tab switch.
    return BlocProvider(
      create: (_) => ChatsCubit()..listenToChats(),
      child: DefaultTabController(
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
                  children: [ChatsScreen(), SearchScreen(), ProfileScreen()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

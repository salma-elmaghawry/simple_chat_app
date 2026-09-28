import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:simple_chat_app/core/routes/app_router.dart';
import 'package:simple_chat_app/core/theme/app_theme.dart';
import 'package:simple_chat_app/features/auth/presentation/cubit/auth_cubit.dart';

class SimpleChatApp extends StatefulWidget {
  /// Only tests pass this, to use a fake. The app uses FirebaseAuth.instance.
  final FirebaseAuth? auth;

  const SimpleChatApp({super.key, this.auth});

  @override
  State<SimpleChatApp> createState() => _SimpleChatAppState();
}

class _SimpleChatAppState extends State<SimpleChatApp> {
  late final StreamSubscription<User?> _authSubscription;

  @override
  void initState() {
    final auth = widget.auth ?? FirebaseAuth.instance;
    _authSubscription = auth.authStateChanges().listen((User? user) {
      if (user == null) {
        log('User is currently signed out!');
      } else {
        log('User is signed in!');
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = AppRouter();

    return BlocProvider(
      create: (_) => AuthCubit(),
      child: ScreenUtilInit(
        designSize: const Size(402, 874),
        builder: (context, child) {
          return MaterialApp(
            title: 'Simple Chat',
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: ThemeMode.system,
            debugShowCheckedModeBanner: false,
            onGenerateRoute: router.generateRoute,
            onUnknownRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: AppBar(title: Text('Page not found')),
                  body: Center(child: Text("We couldn't find that page.")),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

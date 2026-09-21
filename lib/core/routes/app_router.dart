import 'package:flutter/material.dart';
import 'package:simple_chat_app/core/routes/routes.dart';
import 'package:simple_chat_app/features/auth/presentation/screens/login_screen.dart';
import 'package:simple_chat_app/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:simple_chat_app/features/intro/presentation/screens/intro_screen.dart';

class AppRouter {
  Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
      case Routes.intro:
        return MaterialPageRoute(builder: (_) => const IntroScreen());
      case Routes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case Routes.signUp:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      default:
        return null;
    }
  }
}

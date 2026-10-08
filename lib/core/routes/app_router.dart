import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_chat_app/core/routes/routes.dart';
import 'package:simple_chat_app/features/auth/data/models/user_model.dart';
import 'package:simple_chat_app/features/auth/presentation/screens/login_screen.dart';
import 'package:simple_chat_app/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:simple_chat_app/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:simple_chat_app/features/chat/presentation/screens/chat_screen.dart';
import 'package:simple_chat_app/features/home/presentation/screens/home_screen.dart';
import 'package:simple_chat_app/features/intro/presentation/screens/intro_screen.dart';
import 'package:simple_chat_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:simple_chat_app/features/profile/presentation/screens/update_profile_screen.dart';

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
      case Routes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case Routes.updateProfile:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => ProfileCubit(),
            child: const UpdateProfileScreen(),
          ),
        );
      case Routes.chat:
        // The user we tapped in Search or Chats.
        final user = settings.arguments as UserModel;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => ChatCubit(otherUser: user)..listenToMessages(),
            child: ChatScreen(otherUser: user),
          ),
        );
      default:
        return null;
    }
  }
}

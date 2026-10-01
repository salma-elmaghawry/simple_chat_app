import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:simple_chat_app/app.dart';
import 'package:simple_chat_app/core/helpers/cache_helper.dart';
import 'package:simple_chat_app/firebase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await CacheHelper.init();
  // Copy these two values from your Supabase project's Connect dialog.
  await Supabase.initialize(
    url: 'https://ageernnydpcalyjnoibf.supabase.co',
    publishableKey: 'sb_publishable_UkjpWE6Kyrzgh6LLHFOpeg_asJQ7f60',
  );
  runApp(const SimpleChatApp());
}

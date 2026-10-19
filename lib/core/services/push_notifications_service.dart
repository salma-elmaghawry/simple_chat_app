import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:simple_chat_app/core/routes/routes.dart';
import 'package:simple_chat_app/features/auth/data/models/user_model.dart';

class PushNotificationsService {
  static final FirebaseMessaging messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin localNotifications =
      FlutterLocalNotificationsPlugin();

  // Lets us open a screen from outside any widget (on notification tap).
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // The chat on screen right now. No notification for it, the user sees it.
  static String? openChatId;

  // High importance = the notification pops up at the top of the screen.
  // AndroidManifest.xml points FCM to this same id.
  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'chat_messages',
    'Chat messages',
    description: 'New messages from your chats',
    importance: Importance.high,
  );

  // Everyone who logs in gets the messages sent to this topic.
  static const String announcementsTopic = 'announcements';

  //<< -- call once in main() -- >>
  static Future<void> init() async {
    // While the app is open, Android doesn't show FCM notifications,
    // so we show them ourselves with flutter_local_notifications.
    if (Platform.isAndroid) {
      await localNotifications.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
        onDidReceiveNotificationResponse: (response) {
          final payload = response.payload;
          if (payload == null) return;
          openChat(jsonDecode(payload) as Map<String, dynamic>);
        },
      );
      await localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);
    }

    // App is open.
    FirebaseMessaging.onMessage.listen(showForegroundNotification);
    // App is in the background and the user taps the notification.
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) => openChat(message.data),
    );
    // The token can change, so keep Firestore up to date.
    messaging.onTokenRefresh.listen(saveToken);
  }

  //<< -- call after login, in HomeScreen -- >>
  static Future<void> setupForUser() async {
    try {
      // Android 13+ and iOS show the "Allow notifications?" dialog.
      await messaging.requestPermission();

      final String? token = await messaging.getToken();
      log('FCM token: $token');
      if (token != null) await saveToken(token);

      // The app was closed and the user opened it by tapping a notification.
      final RemoteMessage? initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) openChat(initialMessage.data);

      // Join the topic, so messages sent to it reach this phone too.
      await messaging.subscribeToTopic(announcementsTopic);
    } catch (e) {
      // Don't block the app if notifications fail (e.g. iOS simulator).
      log(e.toString());
    }
  }

  //<< -- save this device's token: users/{uid}.fcmToken -- >>
  static Future<void> saveToken(String token) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'fcmToken': token,
    });
  }

  //<< -- call on logout: stop getting the topic's messages -- >>
  static Future<void> unsubscribeFromTopics() =>
      messaging.unsubscribeFromTopic(announcementsTopic);

  //<< -- show a notification while the app is open (Android) -- >>
  static void showForegroundNotification(RemoteMessage message) {
    final RemoteNotification? notification = message.notification;
    if (notification == null || !Platform.isAndroid) return;
    // openChatId is null when no chat is open, so check it first.
    if (openChatId != null && message.data['chatId'] == openChatId) return;

    localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  //<< -- on tap: open the chat with the person who sent the message -- >>
  static Future<void> openChat(Map<String, dynamic> data) async {
    final String? senderId = data['senderId'] as String?;
    if (senderId == null) return;
    // Already inside this chat, no need to open it again.
    if (openChatId != null && data['chatId'] == openChatId) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(senderId)
        .get();
    if (!userDoc.exists) return;

    navigatorKey.currentState?.pushNamed(
      Routes.chat,
      arguments: UserModel.fromJson(userDoc.data()!),
    );
  }
}

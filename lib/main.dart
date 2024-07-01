import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music/screens/library.dart';
import 'package:music/screens/signIn.dart';
import 'package:music/services/auto_login_service.dart';
import 'package:music/services/firebase_push_notification_message_service.dart';
import 'package:music/services/googleapis_httpv1_service.dart';
import 'screens/home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> _receiveNotification(RemoteMessage remoteMessage) async {
  if (remoteMessage.notification != null) {
    print("some thing are here");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FlutterDownloader.initialize(debug: true, ignoreSsl: true);

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );

  await MessagingService().initNotification();
  await MessagingService.initLocalNotification();

  FirebaseMessaging.onBackgroundMessage(_receiveNotification);

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage remoteMessage) {
    if (remoteMessage.notification != null) {
      print("Notification is tapped");
      print(remoteMessage.data);
    }
  });

  FirebaseMessaging.onMessage.listen((RemoteMessage remoteMessage) {
    if (remoteMessage.notification != null) {
      final payload = jsonEncode(remoteMessage.data);
      print("foreground notification");
      MessagingService.showSimpleNotification(
          title: remoteMessage.notification!.title!,
          body: remoteMessage.notification!.body!,
          payload: payload);
    }
  });

  print("${await HTTPv1Service.getAccessToken()} pppppppp");
  runApp(MaterialApp(
    navigatorKey: navigatorKey,
    theme: ThemeData(brightness: Brightness.light),
    home: const AutoLogin(),
    routes: {
      '/home': (context) => const Home(),
      '/library': (context) => const Library(),
      '/signIn': (context) => const SignIn()
    },
  ));
}

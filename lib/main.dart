import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music/models/Song.dart';
import 'package:music/screens/gallery.dart';
import 'package:music/screens/signIn.dart';
import 'package:music/services/auto_login_service.dart';
import 'package:music/services/receive_cloud_messaging_service.dart';
import 'package:provider/provider.dart';
import 'screens/home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:music/firebase_options.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> _receiveNotification(RemoteMessage remoteMessage) async {
  if (remoteMessage.notification != null) {
    navigatorKey.currentState!.pushNamed('/library', arguments: remoteMessage);
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
      navigatorKey.currentState!
          .pushNamed('/gallery', arguments: remoteMessage);
    }
  });

  FirebaseMessaging.onMessage.listen((RemoteMessage remoteMessage) {
    if (remoteMessage.notification != null) {
      final payload = jsonEncode(remoteMessage.data);
      print("foreground from notification");
      MessagingService.showSimpleNotification(
          title: remoteMessage.notification!.title!,
          body: remoteMessage.notification!.body!,
          payload: payload);
    }
  });

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => SongProvider(),
      )

    ],
    child: MaterialApp(
      navigatorKey: navigatorKey,
      theme: ThemeData(brightness: Brightness.light),
      home: const Gallery(),
      routes: {
        '/home': (context) => const Home(),
        '/gallery': (context) => const Gallery(),
        '/signIn': (context) => const SignIn()
      },
    ),
  ));
}

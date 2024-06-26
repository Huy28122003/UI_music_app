import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music/screens/gallery.dart';
import 'package:music/screens/library.dart';
import 'package:music/services/auto_login_service.dart';
import 'screens/home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FlutterDownloader.initialize(
      debug: true,
      ignoreSsl: true
  );

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );

  runApp(MaterialApp(
      theme: ThemeData(brightness: Brightness.light),
      home: const AutoLogin(),
    routes: {
      '/home': (context) => const Home(),
      '/library': (context) =>  Library()
    },
  )
  );

}




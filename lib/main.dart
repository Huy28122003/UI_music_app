import 'package:flutter_downloader/flutter_downloader.dart';

import './home.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(
      debug: true,
      ignoreSsl: true
  );
  runApp(MaterialApp(
      theme: ThemeData(brightness: Brightness.dark), home: const Home()));
}



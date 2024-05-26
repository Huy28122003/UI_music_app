import 'package:flutter_downloader/flutter_downloader.dart';
import './home.dart';
import 'package:flutter/material.dart';
import 'test.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(
      debug: true,
      ignoreSsl: true
  );
  runApp(MaterialApp(
      theme: ThemeData(brightness: Brightness.light), home: const Test()));
}



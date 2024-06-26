import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music/models/FirebaseTrack.dart';
import 'package:music/models/Tracker.dart';
import 'package:music/screens/library.dart';
import 'package:music/services/firebase_tracker_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/firebase_track_service.dart';

class SongManager {
  final FirebaseSong _firebaseSong = FirebaseSong();
  final FirebaseTracker _firebaseTracker = FirebaseTracker();
  late Future<List<Song>> _dataFavorite;
  late Future<List<Song>> _dataPlaylists;

  late List<Song> _playlists = [];
  late List<Song> _favorite = [];

  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  Duration _bufferedPosition = Duration.zero;
  String _currentLocal = "";

  late int _currentSong;
  late String _localSong;
  int _numberSong = -1;
  late String _playState;

  Future<List<Song>> getFavoriteList() async {
    Tracker? tracker =
        await _firebaseTracker.getUser(FirebaseAuth.instance.currentUser!.uid);
    _favorite.clear();

    for (var i in tracker!.likes) {
      Song? song = await _firebaseSong.getSong(i);
      if (song != null) {
        _favorite.add(song);
        print(song.name);
      }
    }
    return _favorite;
  }

  SongManager() {
    _dataFavorite = getFavoriteList();
    _dataPlaylists = _firebaseSong.getSongsFromCollection("playlists");
    getData();
  }

  void getData() async {
    _favorite = await _dataFavorite;
    _playlists = await _dataPlaylists;
  }

  List<Song> get favorite => _favorite;

  Future<List<Song>> get dataFavorite => _dataFavorite;

  Future<List<Song>> get dataPlaylists => _dataPlaylists;

  List<Song> get playlists => _playlists;

  String get currentLocal => _currentLocal;

  set currentLocal(String value) {
    _currentLocal = value;
  }

  String get localSong => _localSong;

  set localSong(String value) {
    _localSong = value;
  }

  int get currentSong => _currentSong;

  set currentSong(int value) {
    _currentSong = value;
  }

  String get playState => _playState;

  set playState(String value) {
    _playState = value;
  }

  Duration get duration => _duration;

  set duration(Duration value) {
    _duration = value;
  }

  Duration get position => _position;

  set position(Duration value) {
    _position = value;
  }

  Duration get bufferedPosition => _bufferedPosition;

  set bufferedPosition(Duration value) {
    _bufferedPosition = value;
  }

  int get numberSong => _numberSong;

  set numberSong(int value) {
    _numberSong = value;
  }

  AudioPlayer get audioPlayer => _audioPlayer;

  Future<List<Song>>? getDataWithLocal() {
    if (localSong == "playlists") {
      return _dataPlaylists;
    } else {
      return null;
    }
  }

  Future<void> prepare() async {
    if (localSong != currentLocal) {
      if(_audioPlayer.audioSource != null) {
        _audioPlayer.dispose();
      }
      await _audioPlayer
          .setAudioSource(await manager.createPlaylist(manager.playlists));
      currentLocal = localSong;
    }
    if (currentSong != numberSong) {
      _position = Duration.zero;
      _bufferedPosition = Duration.zero;
      _duration = Duration.zero;
      manager.audioPlayer.seek(Duration.zero, index: manager.currentSong);
      numberSong = currentSong;
    } else {
      manager.audioPlayer.seek(position, index: manager.currentSong);
    }
  }

  Future<ConcatenatingAudioSource> createPlaylist(List<Song> songs) async {
    List<AudioSource> audioSources = [];
    String path = await getPathToFiles();
    for (var song in songs) {
      bool isDownloaded = await findTrackInDevice(toNameStandard(song.name));
      audioSources.add(AudioSource.uri(
        (isDownloaded)
            ? Uri.file("$path/${toNameStandard(song.name)}.mp3")
            : Uri.parse(song.mp3Url),
        tag: MediaItem(
          id: song.id,
          title: song.name,
          artUri: (isDownloaded)
              ? Uri.file("$path/${toNameStandard(song.name)}.png")
              : Uri.parse(song.imgUrl),
        ),
      ));
    }

    return ConcatenatingAudioSource(children: audioSources);
  }

  Future downLoadFile(String mp3Url, String name, String imgUrl) async {
    String standardName = toNameStandard(name);
    final status = await Permission.storage.request();
    if (status.isGranted) {
      final baseStorage = await getExternalStorageDirectory();
      final taskId = await FlutterDownloader.enqueue(
        url: mp3Url,
        savedDir: baseStorage!.path,
        fileName: '$standardName.mp3',
        showNotification: true,
        openFileFromNotification: true,
      );
      final imageTaskId = await FlutterDownloader.enqueue(
        url: imgUrl,
        savedDir: baseStorage.path,
        fileName: '$standardName.png',
        showNotification: true,
        openFileFromNotification: true,
      );
    }
  }

  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send!.send([id, status, progress]);
  }

  String toNameStandard(String name) {
    String standardName = name.replaceAll(RegExp(r'[^\w\-_\.]'), '_');
    standardName = standardName.replaceAll(RegExp(r'\.{2,}'), '.');
    if (standardName.startsWith('.')) {
      standardName = standardName.substring(1);
    }
    if (standardName.endsWith('.')) {
      standardName = standardName.substring(0, standardName.length - 1);
    }
    return standardName;
  }

  Future<bool> findTrackInDevice(String trackName) async {
    String path = await getPathToFiles();
    Directory directory = Directory(path);
    if (!await directory.exists()) {
      return false;
    } else {
      List<FileSystemEntity> files = await directory.list().toList();
      List<File> mp3Files = files
          .whereType<File>()
          .where((file) => file.path.endsWith('.mp3'))
          .toList();
      List<File> matchingFiles =
          mp3Files.where((file) => file.path.contains(trackName)).toList();
      return matchingFiles.isNotEmpty;
    }
  }

  Future<String> getPathToFiles() async {
    final status = await Permission.storage.request();
    if (status.isGranted) {
      final baseStorage = await getExternalStorageDirectory();
      return baseStorage!.path;
    } else {
      return "";
    }
  }
}

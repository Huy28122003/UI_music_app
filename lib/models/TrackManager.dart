import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'Track.dart';

class TrackManager {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late final Future<List<Track>> _dataFuture;
  late int _currentTrack;
  bool _isPlaying = true;
  bool _isLoop = false;
  double _volume = 1.0;
  final ValueNotifier<Duration> _positionNotifier =
      ValueNotifier(Duration.zero);
  Duration _duration = Duration.zero;
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);
  final ValueNotifier<bool> _isCompleted = ValueNotifier(false);

  Future<List<Track>> getPlaylist() async {
    List<Track> list = [];
    String url = 'https://spotify23.p.rapidapi.com/recommendations/';
    String limit = '20';
    String seed_tracks = '0c6xIDDpzE81m2q797ordA';
    String seed_artists = '4NHQUGzhtTLFvgF5SZesLK';
    String seed_genres = 'classical,country';
    final respone = await http.get(
        Uri.parse(
            "$url?limit=$limit&seed_tracks=$seed_tracks&seed_artists=$seed_artists&seed_genres=$seed_genres"),
        headers: {
          'X-RapidAPI-Key':
              '1a4b64013dmsh7a5b750d379beebp1da407jsnf0b488686b62',
          'X-RapidAPI-Host': 'spotify23.p.rapidapi.com'
        });
    if (respone.statusCode == 200) {
      final data = jsonDecode(respone.body);
      final tracks = data['tracks'] as List;
      for (int i = 0; i < tracks.length; i++) {
        if (tracks[i]['name'] != null &&
            tracks[i]['preview_url'] != null &&
            tracks[i]['album']['images'][2]['url'] != null) {
          String name = tracks[i]['name'];
          String preview_url = tracks[i]['preview_url'];
          String image = tracks[i]['album']['images'][2]['url'];
          Track newTrack = Track(name, preview_url, image);
          list.add(newTrack);
        }
      }
      return list;
    } else {
      return [];
    }
  }

  TrackManager() {
    _dataFuture = getPlaylist();
  }

  Future<List<Track>> get dataFuture => _dataFuture;

  set isPlaying(bool value) {
    _isPlaying = value;
  }

  set isLoop(bool value) {
    _isLoop = value;
  }

  set currentTrack(int value) {
    _currentTrack = value;
  }

  set volume(double value) {
    _volume = value;
  }

  AudioPlayer get audioPlayer => _audioPlayer;

  ValueNotifier<bool> get isCompleted => _isCompleted;

  bool get isPlaying => _isPlaying;

  int get currentTrack => _currentTrack;

  bool get isLoop => _isLoop;

  double get volume => _volume;

  ValueNotifier<Duration> get positionNotifier => _positionNotifier;

  ValueNotifier<bool> get isLoading => _isLoading;

  Duration get duration => _duration;

  void listen() {
    _audioPlayer.onPositionChanged.listen((newPosition) {
      _positionNotifier.value = newPosition;
    });
    _audioPlayer.onDurationChanged.listen((event) {
      _duration = event;
    });
    // _audioPlayer.onPlayerStateChanged.listen((state) async {
    //   if (state == PlayerState.completed) {
    //     _isCompleted.value = true;
    //     positionNotifier.value = Duration.zero;
    //       await playOrpause(_currentTrack + 1);
    //     }
    // });
  }

  void setPlay() {
    _audioPlayer.setVolume(_volume);
    if (_isLoop) {
      _audioPlayer.setReleaseMode(ReleaseMode.loop);
    } else {
      _audioPlayer.setReleaseMode(ReleaseMode.release);
    }
  }

  Future<void> playOrpause(int id) async {
    List<Track> tracks = await _dataFuture;
    print("So luong bai hatttttttttttt ${tracks.length}");
    print("Bai hat hien taiiiiiiiiiiii $_currentTrack");

    try {
      if (id >= 0 && id < tracks.length) {
        bool isDownloaded = await findTrackInLocal(tracks[id].name);
        print("oooooooooooooooooooooooooooooo$isDownloaded");
        if (_isPlaying) {
          if (isDownloaded) {
            await _audioPlayer.play(DeviceFileSource(
                "storage/emulated/0/Android/data/com.example.ui_music_app/files/${tracks[id].name}.mp3"));
            _currentTrack = id;
          } else {
            _isLoading.value = true;
            print("Oldddddddddddddddddddd $_currentTrack");
            Source source = UrlSource(tracks[id].preview_url);
            positionNotifier.value = Duration.zero;
            await _audioPlayer.setSource(source);
            await _audioPlayer.play(source);
            _currentTrack = id;
            _isCompleted.value = false;
            print("Newwwwwwwwwwwwwwwwww $_currentTrack");
            _isLoading.value = false;
          }
        } else {
          _audioPlayer.pause();
          _currentTrack = id;
        }
      } else {
        print("Đã phát hết danh sách");
      }
    } catch (e) {
      print("Looiiiiiiiiii $e");
    }
  }

  Future<bool> findTrackInLocal(String trackName) async {
    Directory directory = Directory(
        '/storage/emulated/0/Android/data/com.example.ui_music_app/files');
    if (!await directory.exists()) {
      return false;
    }
    else {
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

  Future downLoadFile(String url, String name) async {
    final status = await Permission.storage.request();
    if (status.isGranted) {
      final baseStorage = await getExternalStorageDirectory();
      final taskId = await FlutterDownloader.enqueue(
        url: url,
        savedDir: baseStorage!.path,
        fileName: '$name.mp3',
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

  void seek(Duration position) {
    if (position != _duration) {
      _audioPlayer.seek(position);
    }
  }
}

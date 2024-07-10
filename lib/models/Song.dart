import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music/models/Default.dart';
import 'package:music/models/ISongDataSource.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'FirebaseTrack.dart';

class SongProvider extends ChangeNotifier {
  late SongDataSource _songDataSource;

  late List<Song> _playlists = [];
  late List<Song> _favorite = [];
  late List<Song> _downloads = [];
  late List<Song> _hot = [];
  late List<Song> _recent = [];

  int _currentSong = -2;
  int _saveSong = -1;
  String _saveLocal = "";
  late String _currentLocal;


  bool _isVolume =false;
  bool _isLoop = false;
  bool _isLike = false;

  late AudioPlayer _audioPlayer;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  Duration _bufferedPosition = Duration.zero;

  SongProvider() {
    _audioPlayer = AudioPlayer();
    registerListeners();
    _songDataSource = SongDataSourceFactory.create('playlist');
    loadData("playlist");

    _songDataSource = SongDataSourceFactory.create('hot');
    loadData("hot");

    _songDataSource = SongDataSourceFactory.create('favorite');
    loadData("favorite");

    _songDataSource = SongDataSourceFactory.create('download');
    loadData("download");
  }
  void dispose() {
    // _audioPlayer.dispose();
    // _favorite.clear();
    _position = Duration.zero;
    _bufferedPosition = Duration.zero;
    _duration = Duration.zero;
    _currentSong = -2;
    _saveSong = -1;
    _saveLocal = "";
  }

  Future<void> loadData(String position) async {
    switch (position) {
      case "hot":
        _hot = await _songDataSource.getSong();
        break;
      case "favorite":
        _favorite = await _songDataSource.getSong();
        break;
      case "playlist":
        _playlists = await _songDataSource.getSong();
        break;
      default:
        _downloads = await _songDataSource.getSong();
        break;
    }
    notifyListeners();
  }

  void setDataSource(String value) {
    _songDataSource = SongDataSourceFactory.create(value);
  }

  bool get isLike => _isLike;

  set isLike(bool value) {
    _isLike = value;
    notifyListeners();
  }

  bool get isLoop => _isLoop;

  set isLoop(bool value) {
    _isLoop = value;
    notifyListeners();
  }

  bool get isVolume => _isVolume;

  set isVolume(bool value) {
    _isVolume = value;
    notifyListeners();
  }

  List<Song> get recent => _recent;

  set recent(List<Song> value) {
    _recent = value;
  }

  Duration get bufferedPosition => _bufferedPosition;

  set bufferedPosition(Duration value) {
    _bufferedPosition = value;
    notifyListeners();
  }

  Duration get position => _position;

  set position(Duration value) {
    _position = value;
    notifyListeners();
  }

  Duration get duration => _duration;

  set duration(Duration value) {
    _duration = value;
    notifyListeners();
  }

  List<Song> get hot => _hot;

  set hot(List<Song> value) {
    _hot = value;
  }

  List<Song> get downloads => _downloads;

  set downloads(List<Song> value) {
    _downloads = value;
  }

  List<Song> get favorite => _favorite;

  set favorite(List<Song> value) {
    _favorite = value;
  }

  List<Song> get playlists => _playlists;

  set playlists(List<Song> value) {
    _playlists = value;
  }

  String get currentLocal => _currentLocal;

  set currentLocal(String value) {
    _currentLocal = value;
  }

  int get currentSong => _currentSong;

  set currentSong(int value) {
    _currentSong = value;
    notifyListeners();
  }

  AudioPlayer get audioPlayer => _audioPlayer;

  set audioPlayer(AudioPlayer value) {
    _audioPlayer = value;
  }

  void getDataWithPosition() {
    if (currentLocal == "hot") {
      _recent = _hot;
    } else if (currentLocal == "favorite") {
      _recent = _favorite;
    } else if (currentLocal == "download") {
      _recent = _downloads;
    } else if (currentLocal == "playlist") {
      _recent = _playlists;
    } else {
      _recent = [];
    }
  }

  Future<void> prepare() async {
    int cacheCurrent = currentSong;
    if (currentLocal != _saveLocal) {
      if (_saveLocal != "") { // khong phai lan dau tien chon bai khi mo app
        _audioPlayer.dispose();
        _saveSong = -1;
        position = Duration.zero;
        duration = Duration.zero;
        bufferedPosition = Duration.zero;
        _audioPlayer = AudioPlayer();
        registerListeners();
      }
      recent.clear();
      getDataWithPosition();
      await _audioPlayer.setAudioSource(await createPlaylist(_recent));
      _saveLocal = currentLocal;
    }
    if (cacheCurrent != _saveSong) {
      _position = Duration.zero;
      _bufferedPosition = Duration.zero;
      _duration = Duration.zero;
      _audioPlayer.seek(Duration.zero, index: cacheCurrent);
      _saveSong = currentSong;
    }
  }

  Future<void> play() async {
    await _audioPlayer.play();
    notifyListeners();
  }

  Future<void> pause()async{
    await _audioPlayer.pause();
    notifyListeners();
  }

  void registerListeners() {
    _audioPlayer.durationStream.listen((newduration) {
      duration = newduration ?? Duration.zero;
      notifyListeners();
    });
    _audioPlayer.positionStream.listen((newposition) {
      position = newposition;
      notifyListeners();
    });
    _audioPlayer.bufferedPositionStream.listen((newbufferedPosition) {
      bufferedPosition = newbufferedPosition;
      notifyListeners();
    });
    _audioPlayer.sequenceStateStream.listen((sequenceState) {
      currentSong = sequenceState!.currentIndex;
      notifyListeners();
    });
  }

  Future<ConcatenatingAudioSource> createPlaylist(List<Song> songs) async {
    List<AudioSource> audioSources = [];
    String path = await DeviceStoragePath().getPath();
    for (var song in songs) {
      bool isDownloaded =_downloads.any((s) => s.name == toNameStandard(song.name));
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

  Future<List<Song>> getListWithName(String name) async {
    List<Song> result = [];
    _playlists.forEach((element) {
      if (element.name.toLowerCase().contains(name)) {
        result.add(element);
      }
    });
    return result;
  }

  int getPositionInList(String name) {
    return _playlists.indexWhere(
        (element) => element.name.toLowerCase() == name.toLowerCase());
  }
}

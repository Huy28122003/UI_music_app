import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music/models/FirebaseTrack.dart';
import 'package:music/models/ISongDataSource.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class SongManager {
  late SongDataSource _songDataSource;

  late List<Song> _playlists = [];
  late List<Song> _favorite = [];
  late List<Song> _downloads = [];
  late List<Song> _hot = [];

  late AudioPlayer _audioPlayer;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  Duration _bufferedPosition = Duration.zero;
  String _currentLocal = "";

  late int _currentSong;
  late String _localSong;
  int _numberSong = -1;
  late String _playState;
  late bool _isSelected = false;
  late bool _isLike = false;

  SongManager() {
    _audioPlayer = AudioPlayer();

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
    _audioPlayer.dispose();
    _favorite.clear();
    _position = Duration.zero;
    _bufferedPosition = Duration.zero;
    _duration = Duration.zero;
    _isSelected = false;
    _currentSong = -2;
    _currentLocal = "";
  }

  void setDataSource(String value) {
    _songDataSource = SongDataSourceFactory.create(value);
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
  }

  List<Song> get hot => _hot;

  set hot(List<Song> value) {
    _hot = value;
  }

  List<Song> get favorite => _favorite;

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

  List<Song> get downloads => _downloads;

  set downloads(List<Song> value) {
    _downloads = value;
  }

  bool get isLike => _isLike;

  set isLike(bool value) {
    _isLike = value;
  }

  bool get isSelected => _isSelected;

  set isSelected(bool value) {
    _isSelected = value;
  }

  set favorite(List<Song> value) {
    _favorite = value;
  }

  set playlists(List<Song> value) {
    _playlists = value;
  }

  List<Song>? getDataWithPosition() {
    if (localSong == "hot") {
      return _hot;
    } else if (localSong == "favorite") {
      return _favorite;
    } else if (localSong == "download") {
      return _downloads;
    } else if (localSong == "playlist") {
      return _playlists;
    } else {
      return null;
    }
  }

  Future<void> prepare() async {
    if (localSong != currentLocal) {
      _audioPlayer.dispose();

      if (currentLocal != "") {
        numberSong = -1;
        position = Duration.zero;
        duration = Duration.zero;
        bufferedPosition = Duration.zero;
      }
      _audioPlayer = AudioPlayer();
      if (localSong == "playlist") {
        await _audioPlayer.setAudioSource(await createPlaylist(playlists));
      } else if (localSong == "favorite") {
        await _audioPlayer.setAudioSource(await createPlaylist(favorite));
      } else if (localSong == "download") {
        await _audioPlayer.setAudioSource(await createPlaylist(downloads));
      } else if (localSong == "hot") {
        await _audioPlayer.setAudioSource(await createPlaylist(hot));
      }
      currentLocal = localSong;
    }
    if (currentSong != numberSong) {
      _position = Duration.zero;
      _bufferedPosition = Duration.zero;
      _duration = Duration.zero;
      audioPlayer.seek(Duration.zero, index: currentSong);
      numberSong = currentSong;
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

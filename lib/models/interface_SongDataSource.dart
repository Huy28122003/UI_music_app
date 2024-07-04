  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:music/models/FirebaseTrack.dart';
  import 'package:music/models/Tracker.dart';
  import 'package:music/services/firebase_track_service.dart';
  import 'package:music/services/firebase_tracker_service.dart';
  import 'dart:io';
  import 'package:path_provider/path_provider.dart';
  import 'package:permission_handler/permission_handler.dart';

  abstract class SongDataSource {
    Future<List<Song>> getSong();
  }

  class LocalSongDataSource implements SongDataSource {
    @override
    Future<List<Song>> getSong() async {
      final status = await Permission.storage.request();
      if (status.isGranted) {
        final baseStorage = await getExternalStorageDirectory();
        List<FileSystemEntity> files = await baseStorage!.list().toList();
        List<File> mp3Files = files
            .whereType<File>()
            .where((file) => file.path.endsWith('.mp3'))
            .toList();
        List<File> imgFiles = files
            .whereType<File>()
            .where((file) => file.path.endsWith('.png'))
            .toList();
        List<Map<String, String>> listImg = [];
        for (int i = 0; i < imgFiles.length; i++) {
          String imgName =
              imgFiles[i].path.substring(imgFiles[i].path.lastIndexOf('/') + 1);
          String imgPath = imgFiles[i].path;
          listImg.add({
            'name': imgName,
            'path': imgPath,
          });
        }

        List<Song> list = [];
        for (int i = 0; i < mp3Files.length; i++) {
          String name =
              mp3Files[i].path.substring(mp3Files[i].path.lastIndexOf('/') + 1);
          String preview_url = mp3Files[i].path;
          for (var img in listImg) {
            var imgName = img['name'];
            if (imgName != null &&
                imgName.substring(0, imgName.length - 4) ==
                    name.substring(0, name.length - 4)) {
              var imgPath = img['path'];
              if (imgPath != null) {
                String image = imgPath;
                Song newTrack = Song(
                    "",
                    name.substring(0, name.length - 4),
                    image.substring(0, image.length - 4),
                    preview_url.substring(0, preview_url.length - 4),
                    0);
                list.add(newTrack);
                break;
              }
            }
          }
        }
        return list;
      } else {
        return [];
      }
    }
  }

  class FirebaseSongDataSource implements SongDataSource {
    final FirebaseSong _firebaseSong = FirebaseSong();

    @override
    Future<List<Song>> getSong() async {
      return await _firebaseSong.getSongsFromCollection("playlists");
    }
  }

  class FavoriteSongDataSource implements SongDataSource {
    final FirebaseTracker _firebaseTracker = FirebaseTracker();

    @override
    Future<List<Song>> getSong() async {
      List<Song> _favorite = [];
      Tracker? tracker =
          await _firebaseTracker.getUser(FirebaseAuth.instance.currentUser!.uid);
      _favorite.clear();

      for (var i in tracker!.likes) {
        Song? song = await FirebaseSong().getSong(i);
        if (song != null) {
          _favorite.add(song);
        }
      }
      return _favorite;
    }
  }

  class HotSongDataSource implements SongDataSource {
    @override
    Future<List<Song>> getSong() async {
      final FirebaseSong _firebaseSong = FirebaseSong();

      List<Song> playlists =
          await _firebaseSong.getSongsFromCollection("playlists");
      playlists.sort((a, b) => (b.likes).compareTo(a.likes));
      return playlists;
    }
  }

  class SongDataSourceFactory{
    static SongDataSource create(String sourceType) {
      switch (sourceType) {
        case 'playlist':
          return FirebaseSongDataSource();
        case 'download':
          return LocalSongDataSource();
        case 'favorite':
          return FavoriteSongDataSource();
        case 'hot':
          return HotSongDataSource();
        default:
          throw ArgumentError('Invalid source type');
      }
    }
  }

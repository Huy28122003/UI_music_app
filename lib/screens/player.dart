import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:just_audio/just_audio.dart';
import 'package:marquee/marquee.dart';
import 'package:music/models/FirebaseTrack.dart';
import 'package:music/models/Song.dart';
import 'package:music/models/SongManager.dart';
import 'package:music/services/firebase_track_service.dart';
import 'package:music/services/firebase_tracker_service.dart';
import 'package:music/widgets/box.dart';
import 'package:provider/provider.dart';

class Player extends StatefulWidget {
  const Player({super.key});

  @override
  State<Player> createState() => _RunState();
}

class _RunState extends State<Player> {
  final ReceivePort _port = ReceivePort();
  FirebaseTracker _firebaseTracker = FirebaseTracker();
  FirebaseSong _firebaseSong = FirebaseSong();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final manager = Provider.of<SongProvider>(context, listen: false);
      manager.play();
      manager.isLike = false;
      manager.isLike = manager.favorite.any((song) =>
          song.id == manager.audioPlayer.sequenceState!.currentSource!.tag.id);
    });
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      setState(() {});
    });
    FlutterDownloader.registerCallback(SongManager.downloadCallback);
  }

  @override
  void dispose() {
    super.dispose();
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    _port.close();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: const Text("R u n n e r"),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Consumer<SongProvider>(builder: (context, manager, child) {
              return Column(
                children: [
                  NeuBox(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: (manager.currentLocal == "download")
                          ? Image.file(
                              File(
                                  "${manager.recent[manager.currentSong].imgUrl}.png"),
                              height: 200,
                              width: 200,
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              manager.recent[manager.currentSong].imgUrl,
                              height: 200,
                              width: 200,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 30,
                    child: Marquee(
                      text: manager.recent[manager.currentSong].name,
                      style: const TextStyle(fontSize: 24, color: Colors.amber),
                      velocity: 10.0,
                      blankSpace: 20.0,
                      scrollAxis: Axis.horizontal,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      pauseAfterRound: const Duration(seconds: 1),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () {
                          manager.downLoadFile(
                            manager.recent[manager.currentSong].mp3Url,
                            manager.recent[manager.currentSong].name,
                            manager.recent[manager.currentSong].imgUrl,
                          );
                        },
                        icon: const Icon(Icons.download),
                        iconSize: 30,
                      ),
                      IconButton(
                        onPressed: (manager.currentLocal == "download")
                            ? null
                            : () async {
                                manager.isLike = !manager.isLike;

                                _firebaseSong.updateToLikes(
                                    manager.recent[manager.currentSong].id,manager.isLike);
                                _firebaseTracker.updateSongToLikes(
                                    manager.recent[manager.currentSong].id,manager.isLike);
                                manager.setDataSource("favorite");
                                manager.loadData("favorite");
                              },
                        icon: (manager.isLike)
                            ? const Icon(
                                Icons.favorite,
                                color: Colors.yellow,
                              )
                            : const Icon(
                                Icons.favorite_border,
                                color: Colors.black,
                              ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.access_alarm_outlined),
                        iconSize: 30,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ProgressBar(
                    progress: manager.position,
                    buffered: manager.bufferedPosition,
                    total: manager.duration,
                    onSeek: (duration) {
                      manager.audioPlayer.seek(duration);
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () {
                          manager.isLoop = !manager.isLoop;
                          if (manager.isLoop) {
                            manager.audioPlayer.setLoopMode(LoopMode.one);
                          } else {
                            manager.audioPlayer.setLoopMode(LoopMode.off);
                          }
                        },
                        icon: _setIconLoop(manager),
                        iconSize: 30,
                      ),
                      IconButton(
                        onPressed: () {
                          manager.audioPlayer.seekToPrevious();
                        },
                        icon: const Icon(
                          Icons.skip_previous,
                          size: 40,
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          if (manager.audioPlayer.playing) {
                            manager.pause();
                          } else {
                            manager.play();
                          }
                        },
                        icon: _setIconPlaying(manager),
                        iconSize: 40,
                      ),
                      IconButton(
                        onPressed: () {
                          manager.audioPlayer.seekToNext();
                        },
                        icon: const Icon(
                          Icons.skip_next,
                          size: 40,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          manager.isVolume = !manager.isVolume;
                        },
                        icon: const Icon(
                          Icons.volume_up,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                  if (manager.isVolume)
                    SizedBox(
                      width: 200,
                      child: Slider(
                        value: manager.audioPlayer.volume,
                        onChanged: (value) {
                          setState(() {
                            manager.audioPlayer.setVolume(value);
                          });
                        },
                        activeColor: Colors.blue,
                        inactiveColor: Colors.grey,
                      ),
                    ),
                ],
              );
            }),
          )),
    );
  }

  Icon _setIconPlaying(SongProvider manager) {
    if (manager.audioPlayer.playing) {
      return const Icon(
        Icons.pause,
        size: 40,
      );
    } else {
      return const Icon(
        Icons.play_arrow,
        size: 40,
      );
    }
  }

  Icon _setIconLoop(SongProvider manager) {
    if (manager.isLoop) {
      return const Icon(
        Icons.repeat_one_rounded,
        size: 40,
      );
    } else {
      return const Icon(
        Icons.repeat,
        size: 40,
      );
    }
  }
}

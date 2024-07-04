import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:just_audio/just_audio.dart';
import 'package:marquee/marquee.dart';
import 'package:music/models/FirebaseTrack.dart';
import 'package:music/models/SongManager.dart';
import 'package:music/services/firebase_track_service.dart';
import 'package:music/services/firebase_tracker_service.dart';
import 'package:music/widgets/box.dart';
import '../services/auto_login_service.dart';
import 'library.dart';

class Run extends StatefulWidget {
  const Run({super.key});

  @override
  State<Run> createState() => _RunState();
}

class _RunState extends State<Run> {
  FirebaseTracker _firebaseTracker = FirebaseTracker();
  FirebaseSong _firebaseSong = FirebaseSong();
  bool _showVolume = false;
  final ReceivePort _port = ReceivePort();
  List<Song> data = [];

  void _registerListeners() {
    manager.audioPlayer.durationStream.listen((duration) {
      if (mounted) {
        setState(() {
          manager.duration = duration ?? Duration.zero;
        });
      }
    });
    manager.audioPlayer.positionStream.listen((position) {
      manager.position = position;
      if (mounted) {
        setState(() {});
      }
    });
    manager.audioPlayer.bufferedPositionStream.listen((bufferedPosition) {
      if (mounted) {
        setState(() {
          manager.bufferedPosition = bufferedPosition;
        });
      }
    });
    manager.audioPlayer.sequenceStateStream.listen((sequenceState) {
      if (sequenceState != null && mounted) {
        setState(() {
          manager.currentSong = sequenceState.currentIndex;
        });
      }
    });
  }

  void run() async {
    await manager.audioPlayer.play();
  }

  @override
  void initState() {
    super.initState();
    data = manager.getDataWithPosition()!;
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      setState(() {});
    });
    FlutterDownloader.registerCallback(SongManager.downloadCallback);
    run();
    _registerListeners();
    manager.isLike = false;
    manager.isLike = manager.favorite.any((song) =>
        song.id == manager.audioPlayer.sequenceState!.currentSource!.tag.id);
    manager.isSelected = true;
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    _port.close();
    super.dispose();
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
          child: Column(
            children: [
              NeuBox(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: (manager.localSong == "download")
                      ? Image.file(
                    File("${data[manager.currentSong].imgUrl}.png"),
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                  )
                      : Image.network(
                    data[manager.currentSong].imgUrl,
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 30, // Adjust the height as needed
                child: Marquee(
                  text: data[manager.currentSong].name,
                  style:
                  const TextStyle(fontSize: 24, color: Colors.amber),
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
                        data[manager.currentSong].mp3Url,
                        data[manager.currentSong].name,
                        data[manager.currentSong].imgUrl,
                      );
                    },
                    icon: const Icon(Icons.download),
                    iconSize: 30,
                  ),
                  IconButton(
                    onPressed: (manager.localSong == "download")
                        ? null
                        : () async {
                      setState(() {
                        manager.isLike = !manager.isLike;
                      });
                      _firebaseSong.updateToLikes(
                          data[manager.currentSong].id);
                      _firebaseTracker.updateSongToLikes(
                          data[manager.currentSong].id);
                      // manager.dataFavorite =
                      //     manager.getFavoriteList();
                      // manager.favorite = await manager.dataFavorite;
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
                      setState(() {
                        if (manager.audioPlayer.loopMode ==
                            LoopMode.one) {
                          manager.audioPlayer.setLoopMode(LoopMode.off);
                        } else {
                          manager.audioPlayer.setLoopMode(LoopMode.one);
                        }
                      });
                    },
                    icon: _setIconLoop(),
                    iconSize: 30,
                  ),
                  IconButton(
                    onPressed: () {
                      manager.audioPlayer.seekToPrevious();
                      setState(() {
                        manager.currentSong = manager
                            .audioPlayer.sequenceState!.currentIndex;
                      });
                    },
                    icon: const Icon(
                      Icons.skip_previous,
                      size: 40,
                    ),
                  ),
                  StreamBuilder<PlayerState>(
                    stream: manager.audioPlayer.playerStateStream,
                    builder: (context, snapshot) {
                      final playerState = snapshot.data;
                      final processingState =
                          playerState?.processingState;
                      if (processingState == ProcessingState.loading ||
                          processingState == ProcessingState.buffering) {
                        return const CircularProgressIndicator();
                      } else {
                        return IconButton(
                          onPressed: () {
                            setState(() {
                              if (manager.audioPlayer.playing) {
                                manager.audioPlayer.pause();
                              } else {
                                manager.audioPlayer.play();
                              }
                            });
                          },
                          icon: _setIconPlaying(),
                          iconSize: 40,
                        );
                      }
                    },
                  ),
                  IconButton(
                    onPressed: () {
                      manager.audioPlayer.seekToNext();
                      setState(() {
                        manager.currentSong = manager
                            .audioPlayer.sequenceState!.currentIndex;
                      });
                    },
                    icon: const Icon(
                      Icons.skip_next,
                      size: 40,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _showVolume = !_showVolume;
                      });
                    },
                    icon: const Icon(
                      Icons.volume_up,
                      size: 40,
                    ),
                  ),
                ],
              ),
              if (_showVolume)
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
          ),
        )
        ),
      );
  }

  Icon _setIconPlaying() {
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

  Icon _setIconLoop() {
    if (manager.audioPlayer.loopMode == LoopMode.one) {
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

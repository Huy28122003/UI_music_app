import 'dart:isolate';
import 'dart:ui';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music/models/SongManager.dart';
import 'package:music/screens/library.dart';
import 'package:music/widgets/box.dart';

class Run extends StatefulWidget {
  const Run({super.key});

  @override
  State<Run> createState() => _RunState();
}

class _RunState extends State<Run> {
  bool _showVolume = false;
  final ReceivePort _port = ReceivePort();


  void _registerListeners() {
    manager.audioPlayer.durationStream.listen((duration) {
      if (mounted) {
        setState(() {
          manager.duration = duration ?? Duration.zero;
        });
      }
    });
    manager.audioPlayer.positionStream.listen((position) {
      if (mounted) {
        setState(() {
          manager.position = position;
        });
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
    // TODO: implement initState
    super.initState();
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      int status = data[1];
      int progress = data[2];
      setState(() {});
    });
    FlutterDownloader.registerCallback(SongManager.downloadCallback);
    run();
    _registerListeners();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: const Text("R u n e r"),
            ),
            body: FutureBuilder(
                future: manager.getDataWithLocal(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final data = snapshot.data!;
                    return Column(
                      children: [
                        NeuBox(
                            child: ClipRRect(
                          child: Image.network(
                            data[manager.currentSong].imgUrl,
                            fit: BoxFit.fill,
                            height: 200,
                          ),
                        )),
                        Text(data[manager.currentSong].name),
                        Row(children: [
                          Expanded(child: IconButton(onPressed: (){
                            manager.downLoadFile(
                                data[manager.currentSong].mp3Url,
                                data[manager.currentSong].name,
                                data[manager.currentSong].imgUrl);
                          }, icon: const Icon(Icons.download))),
                          Expanded(child: IconButton(onPressed: (){}, icon: Icon(Icons.access_alarm_outlined)))
                        ],),
                        ProgressBar(
                          progress: manager.position,
                          buffered: manager.bufferedPosition,
                          total: manager.duration,
                          onSeek: (duration) {
                            manager.audioPlayer.seek(duration);
                          },
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        if (manager.audioPlayer.loopMode ==
                                            LoopMode.one) {
                                          manager.audioPlayer
                                              .setLoopMode(LoopMode.off);
                                        } else {
                                          manager.audioPlayer
                                              .setLoopMode(LoopMode.one);
                                        }
                                      });
                                    },
                                    icon: _setIconLoop())),
                            Expanded(
                                child: IconButton(
                                        onPressed: () {
                                          manager.audioPlayer.seekToPrevious();
                                          setState(() {
                                            manager.currentSong = manager.audioPlayer.sequenceState!.currentIndex;
                                          });
                                        },
                                        icon: const Icon(Icons.skip_previous,size: 40,))),
                            StreamBuilder<PlayerState>(
                                  stream: manager.audioPlayer.playerStateStream,
                                  builder: (context, snapshot) {
                                    final playerState = snapshot.data;
                                    final processingState = playerState?.processingState;
                                    if (processingState == ProcessingState.loading || processingState == ProcessingState.buffering) {
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
                                      );
                                    }
                                  },
                                ),
                            Expanded(
                                child: IconButton(
                                    onPressed: () {
                                      manager.audioPlayer.seekToNext();
                                      setState(() {
                                        manager.currentSong = manager.audioPlayer.sequenceState!.currentIndex;
                                      });
                                    },
                                    icon: const Icon(Icons.skip_next,size: 40,))),
                            Expanded(
                                child: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _showVolume = !_showVolume;
                                      });
                                    },
                                    icon: const Icon(Icons.volume_up,size: 40,))),
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
                          )
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Text('$snapshot.error');
                  } else {
                    return const CircularProgressIndicator();
                  }
                })));
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
      return const Icon(Icons.repeat_one_rounded,size: 40,);
    } else {
      return const Icon(Icons.repeat,size: 40,);
    }
  }
}

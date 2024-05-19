import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'models/Track.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class Player extends StatefulWidget {
  const Player({super.key});

  @override
  State<StatefulWidget> createState() {
    return _PlayerState();
  }
}

class _PlayerState extends State<Player> {
  final AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;
  bool isLoop = false;
  double volume = 1.0;
  bool showSetVolume = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  late int idTrack,id = -1;
  late List<Track> listTrack;
  ReceivePort _port = ReceivePort();

  Future _downLoadFile(String url,String name) async{
    final status =await Permission.storage.request();
    if(status.isGranted){
      final baseStorage = await getExternalStorageDirectory();
      print(baseStorage!.path);
      final taskId = await FlutterDownloader.enqueue(
        url: url,
        savedDir: baseStorage!.path,
        fileName: '$name.mp3',
        showNotification: true,
        openFileFromNotification: true,
      );
    }
  }

  @override
  void initState() {
    super.initState();

    audioPlayer.setVolume(volume);

    audioPlayer.onPlayerStateChanged.listen((event) {
      if (mounted) {
        setState(() {
          isPlaying = event == PlayerState.playing;
        });
      }
    });
    audioPlayer.onDurationChanged.listen((event) {
      if (mounted) {
        setState(() {
          duration = event;
        });
      }
    });

    audioPlayer.onPositionChanged.listen((event) {
      if (mounted) {
        setState(() {
          position = event;
        });
      }
    });
    audioPlayer.onPlayerComplete.listen((event) {
      if(mounted){
        setState(() {
          position = Duration.zero;
          id++;
        });
      }
    });
    IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0] ;
      int status = data[1];
      int progress = data[2];
      setState((){ });
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  void dispose() {
    super.dispose();
    IsolateNameServer.removePortNameMapping('downloader_send_port');

    audioPlayer.dispose();
  }

  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    final SendPort? send = IsolateNameServer.lookupPortByName('downloader_send_port');
    send!.send([id, status, progress]);
  }

  @override
  Widget build(BuildContext context) {
    Map<String,dynamic> song= ModalRoute.of(context)!.settings.arguments
    as Map<String,dynamic>;
    listTrack = song["listTrack"] as List<Track>;
    idTrack = song["idTrack"] as int;
    if(id<=idTrack){
      id=idTrack;
    }
    else{
      idTrack=id;
    }
    Track track = listTrack[idTrack];
    Source source = UrlSource(track.preview_url);

    return SafeArea(
        child: Scaffold(
      body: Column(
        children: [
          Container(
              margin: EdgeInsets.only(top: 25),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  track.image,
                  height: 250,
                  width: 250,
                  fit: BoxFit.contain,
                ),
              )),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              track.name,
              style: const TextStyle(fontSize: 24, color: Colors.amber),
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.only(left: 40),
                child: IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: ()  {
                    _downLoadFile(track.preview_url, track.name);
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 90),
                child: const Icon(
                  Icons.ios_share,
                  color: Colors.yellow,
                ),
              ),
              Container(
                  margin: const EdgeInsets.only(left: 70),
                  child: Text("${duration.inSeconds - position.inSeconds}s"))
            ],
          ),
          Slider(
            min: 0,
            max:
                duration == Duration.zero ? 0.0 : duration.inSeconds.toDouble(),
            value: position.inSeconds.toDouble(),
            onChanged: (value) async {
              final position = Duration(seconds: value.toInt());
              await audioPlayer.seek(position);

              await audioPlayer.resume();
            },
          ),
          Row(
            children: [
              Expanded(
                  child: IconButton(
                      onPressed: () {
                        setState(() {
                          isLoop = !isLoop;
                        });
                        if (isLoop) {
                          audioPlayer.setReleaseMode(ReleaseMode.loop);
                        } else {
                          audioPlayer.setReleaseMode(ReleaseMode.release);
                        }
                      },
                      icon: _setIconLoop())),
              Expanded(
                  child: IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.skip_previous,
                        size: 30,
                      ))),
              Expanded(
                  child: IconButton(
                      onPressed: () async {
                        if (isPlaying) {
                          await audioPlayer.pause();
                        } else {
                          audioPlayer.play(source);
                        }
                      },
                      icon: _setIconPlaying())),
              Expanded(
                  child: IconButton(
                      onPressed: () {
                        audioPlayer.release();
                        setState(() {
                          position = Duration.zero;
                          id++;
                        });
                      },
                      icon: const Icon(
                        Icons.skip_next,
                        size: 30,
                      ))),
              Expanded(
                  child: IconButton(
                      onPressed: () {
                        setState(() {
                          showSetVolume = !showSetVolume;
                        });
                      },
                      icon: const Icon(Icons.volume_up)))
            ],
          ),
          if (showSetVolume)
            SizedBox(
              width: 200,
              child: Slider(
                value: volume,
                onChanged: (value) {
                  setState(() {
                    volume = value;
                  });
                },
                activeColor: Colors.blue, // Adjust colors as desired
                inactiveColor: Colors.grey,
              ),
            )
        ],
      ),
    ));
  }

  Icon _setIconPlaying() {
    if (isPlaying) {
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
    if (isLoop) {
      return const Icon(Icons.repeat_one_rounded);
    } else {
      return const Icon(Icons.repeat);
    }
  }
}

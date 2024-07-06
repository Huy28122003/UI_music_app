import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music/services/firebase_track_service.dart';
import 'package:music/widgets/verticalList.dart';
import '../screens/profile.dart';
import '../screens/run.dart';
import '../screens/search.dart';
import '../services/auto_login_service.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  FirebaseSong _firebaseSong = FirebaseSong();

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (manager.audioPlayer.playing) {
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (manager.isSelected == true && manager.isSelected != null)
          Container(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        child: TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Run()));
                      },
                      child: Text(
                          "${manager.audioPlayer.sequenceState?.currentSource?.tag.title}"),
                    )),
                    StreamBuilder<PlayerState>(
                      stream: manager.audioPlayer.playerStateStream,
                      builder: (context, snapshot) {
                        final playerState = snapshot.data;
                        final processingState = playerState?.processingState;
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
                          );
                        }
                      },
                    ),
                  ],
                ),
                LinearProgressIndicator(
                  value: (manager.duration != Duration.zero)
                      ? manager.position.inSeconds.toDouble() /
                          manager.duration.inSeconds.toDouble()
                      : 0.0,
                ),
              ],
            ),
          ),
        BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              label: 'Favorite',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.library_add_check),
              label: 'Downloaded',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'User',
            ),
          ],
          onTap: (index) async {
            switch (index) {
              case 0:
                // manager.dataFavorite = manager.getFavoriteList();
                // manager.favorite = await manager.dataFavorite;
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => VerticalList(
                            name: "Favorites",
                            data: manager.favorite,
                            location: "favorite")));
                break;
              case 1:
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Search()));
                break;
              case 2:
                manager.setDataSource("playlist");
                await manager.loadData("playlist");
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/library',
                  (Route<dynamic> route) => false,
                );
                break;
              case 3:
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => VerticalList(
                            name: "Download",
                            data: manager.downloads,
                            location: "download")));
                break;
              case 4:
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Profile()));
                break;
            }
          },
        ),
      ],
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
}

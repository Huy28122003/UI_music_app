import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music/widgets/verticalList.dart';
import '../screens/library.dart';
import '../screens/profile.dart';
import '../screens/run.dart';
import '../screens/search.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (manager.audioPlayer.playing) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
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
                        final processingState =
                            playerState?.processingState;
                        if (processingState ==
                            ProcessingState.loading ||
                            processingState ==
                                ProcessingState.buffering) {
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
              label: 'Profile',
            ),
          ],
          onTap: (index) async {
            switch (index) {
              case 0:
                manager.dataFavorite = manager.getFavoriteList();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => VerticalList(
                            name: "Favorites",
                            data: manager.dataFavorite,
                            location: "favorite")));
                break;
              case 1:
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Search()));
                break;
              case 2:
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/library',
                      (Route<dynamic> route) => false,
                );
                break;
              case 3:
                manager.dataDownloads = manager.getPlaylistFromFolder();
                manager.downloads = await manager.dataDownloads;
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => VerticalList(
                            name: "Download",
                            data: manager.dataDownloads,
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

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music/models/Song.dart';
import 'package:music/screens/player.dart';
import 'package:music/services/firebase_track_service.dart';
import 'package:music/widgets/verticalList.dart';
import 'package:provider/provider.dart';
import '../screens/profile.dart';
import '../screens/search.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  FirebaseSong _firebaseSong = FirebaseSong();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Consumer<SongProvider>(builder: (context, manager, child) {
          if (manager.currentSong != -2 &&
              manager.audioPlayer.position > const Duration(seconds: 0)) {
            return Container(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          child: Text(
                              "${manager.audioPlayer.sequenceState?.currentSource?.tag.title}"),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Player()));
                          },
                        ),
                      ),
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
                                if (manager.audioPlayer.playing) {
                                  manager.pause();
                                } else {
                                  manager.play();
                                }
                              },
                              icon: _setIconPlaying(manager),
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
            );
          } else {
            return const SizedBox.shrink();
          }
        }),
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
              label: 'More',
            ),
          ],
          onTap: (index) async {
            switch (index) {
              case 0:
                Provider.of<SongProvider>(context, listen: false)
                    .setDataSource("favorite");
                await Provider.of<SongProvider>(context, listen: false)
                    .loadData("favorite");
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => VerticalList(
                            name: "Favorites",
                            data: Provider.of<SongProvider>(context,
                                    listen: false)
                                .favorite,
                            location: "favorite")));
                break;
              case 1:
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Search()));
                break;
              case 2:
                Provider.of<SongProvider>(context, listen: false)
                    .setDataSource("playlist");
                await Provider.of<SongProvider>(context, listen: false)
                    .loadData("playlist");
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/gallery',
                  (Route<dynamic> route) => false,
                );
                break;
              case 3:
                Provider.of<SongProvider>(context, listen: false)
                    .setDataSource("download");
                await Provider.of<SongProvider>(context, listen: false)
                    .loadData("download");
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => VerticalList(
                            name: "Download",
                            data: Provider.of<SongProvider>(context,
                                    listen: false)
                                .downloads,
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

  Icon _setIconPlaying(SongProvider manager) {
    if (manager.audioPlayer.playing) {
      return const Icon(
        Icons.pause,
        size: 30,
      );
    } else {
      return const Icon(
        Icons.play_arrow,
        size: 30,
      );
    }
  }
}

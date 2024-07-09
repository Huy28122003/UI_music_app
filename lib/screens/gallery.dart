import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:music/models/Song.dart';
import 'package:music/screens/player.dart';
import 'package:music/services/receive_cloud_messaging_service.dart';
import 'package:music/services/firebase_tracker_service.dart';
import 'package:music/widgets/bottom_navigation_bar.dart';
import 'package:music/widgets/box.dart';
import 'package:provider/provider.dart';

class Gallery extends StatefulWidget {
  const Gallery({super.key});

  @override
  State<Gallery> createState() => _LibraryState();
}

class _LibraryState extends State<Gallery> {
  late PageController _pageController;
  int _currentPage = 0;
  late Timer _timer;
  Map payload = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    set();
  }

  void set() async {
    String fcmToken = await MessagingService().getTokenDevices();
    try {
      FirebaseTracker().updateToken(fcmToken);
    } catch (e) {
      print("Loi cap nhat fcmToken $e");
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_currentPage < 4) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var data = ModalRoute.of(context)!.settings.arguments;
    if (data is RemoteMessage) {
      payload = data.data;
    } else if (data is NotificationResponse) {
      payload = jsonDecode(data.payload!);
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("L i b r a r y"),
        ),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Consumer<SongProvider>(builder: (context, manager, child) {
              return Column(
                children: [
                  SizedBox(
                    height: 200,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        if (index < manager.hot.length) {
                          return Center(
                            child: GestureDetector(
                              child: NeuBox(
                                child: SizedBox(
                                  width: 250,
                                  height: 150,
                                  child: Image.network(
                                    manager.hot[index].imgUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              onTap: () async {
                                manager.currentLocal = "hot";
                                manager.currentSong = index;
                                await manager.prepare();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Player()),
                                );
                              },
                            ),
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    ),
                  ),
                  Expanded(
                      child: ListView.builder(
                    itemCount: manager.playlists.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          leading: FadeInImage.assetNetwork(
                            placeholder: 'assets/images/img8.png',
                            image: manager.playlists[index].imgUrl,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                          title: Text(
                            manager.playlists[index].name,
                            softWrap: true,
                          ),
                          onTap: () async {
                            manager.currentLocal = "playlist";
                            manager.currentSong = index;
                            await manager.prepare();
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Player()),
                            );
                          },
                        ),
                      );
                    },
                  )),
                ],
              );
            })),
        bottomNavigationBar: const BottomBar(),
      ),
    );
  }
}

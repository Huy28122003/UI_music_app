import 'dart:async';
import 'package:flutter/material.dart';
import 'package:music/models/SongManager.dart';
import 'package:music/screens/run.dart';
import 'package:music/widgets/bottom_navigation_bar.dart';
import 'package:music/widgets/box.dart';

SongManager manager = SongManager();

class Library extends StatefulWidget {
  const Library({super.key});

  @override
  State<Library> createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  late PageController _pageController;
  int _currentPage = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_currentPage < manager.favorite.length - 1) {
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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Library"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(
                height: 200,
                child: FutureBuilder(
                  future: manager.dataFavorite,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return PageView.builder(
                        controller: _pageController,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return Center(
                            child: GestureDetector(
                              child: NeuBox(
                                child: SizedBox(
                                  width: 250,
                                  height: 150,
                                  child: Image.network(
                                    snapshot.data![index].imgUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              onTap: () async {
                                manager.currentSong = index;
                                manager.localSong = "favorite";
                                await manager.prepare();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => Run()),
                                );
                              },
                            ),
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(snapshot.error.toString()),
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ),
              Expanded(
                child: FutureBuilder(
                  future: manager.dataPlaylists,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final data = snapshot.data!;
                      return ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              leading: FadeInImage.assetNetwork(
                                placeholder: 'assets/images/img8.png',
                                image: data[index].imgUrl,
                                width: 100,
                                fit: BoxFit.cover,
                              ),
                              title: Text(
                                data[index].name,
                                softWrap: true,
                              ),
                              onTap: () async {
                                manager.currentSong = index;
                                manager.localSong = "playlists";
                                await manager.prepare();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => Run()),
                                );
                              },
                            ),
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(snapshot.error.toString()),
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomBar(),
      ),
    );
  }
}

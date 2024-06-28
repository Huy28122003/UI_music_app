import 'dart:io';
import 'package:flutter/material.dart';
import 'package:music/screens/run.dart';
import 'package:music/widgets/bottom_navigation_bar.dart';
import '../screens/library.dart';

class VerticalList extends StatelessWidget {
  final String name;
  final Future<List<dynamic>> data;
  final String location;

  const VerticalList({
    super.key,
    required this.name,
    required this.data,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(name),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: FutureBuilder(
                  future: data,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final List<dynamic> value = snapshot.data!;
                      return ListView.builder(
                        itemCount: value.length,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              leading: (location == "download")
                                  ? Image.file(
                                File("${value[index].imgUrl}.png"),
                                width: 80,
                                fit: BoxFit.cover,
                              )
                                  : FadeInImage.assetNetwork(
                                placeholder: 'assets/images/img9.png',
                                image: "${value[index].imgUrl}",
                                width: 80,
                                fit: BoxFit.cover,
                              ),
                              title: Text(
                                value[index].name,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () async {
                                manager.currentSong = index;
                                manager.localSong = location;
                                await manager.prepare();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Run(),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Center(child: Text(snapshot.error.toString()));
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const BottomBar(),
      ),
    );
  }
}

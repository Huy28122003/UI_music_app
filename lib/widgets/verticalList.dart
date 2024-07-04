import 'dart:io';
import 'package:flutter/material.dart';
import 'package:music/screens/run.dart';
import 'package:music/widgets/bottom_navigation_bar.dart';
import '../services/auto_login_service.dart';

class VerticalList extends StatelessWidget {
  final String name;
  final List<dynamic> data;
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
                  child: ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: (location == "download")
                          ? Image.file(
                              File("${data[index].imgUrl}.png"),
                              width: 80,
                              fit: BoxFit.cover,
                            )
                          : FadeInImage.assetNetwork(
                              placeholder: 'assets/images/img9.png',
                              image: "${data[index].imgUrl}",
                              width: 80,
                              fit: BoxFit.cover,
                            ),
                      title: Text(
                        data[index].name,
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
              )),
            ],
          ),
        ),
        bottomNavigationBar: const BottomBar(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:music/models/SongManager.dart';
import 'package:music/screens/run.dart';

SongManager manager = SongManager();
class Library extends StatefulWidget {
  const Library({super.key});

  @override
  State<Library> createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      appBar: AppBar(
        title: Text("L i b r a r y"),
      ),
      body: FutureBuilder(
          future: manager.dataPlaylists,
          builder: (context,snapshot){
            if(snapshot.hasData){
              final data = snapshot.data!;
              return ListView(
                children: [
                  for (int i = 0; i < data.length; i++)
                    GestureDetector(
                      child: Row(
                        children: [
                          FadeInImage.assetNetwork(
                            placeholder: 'assets/images/img8.png',
                            image: data[i].imgUrl,
                            width: 100,
                          ),
                          Expanded(
                            child: Text(
                              data[i].name,
                              softWrap: true,
                            ),
                          )
                        ],
                      ),
                      onTap: () async {
                        manager.currentSong = i;
                        manager.localSong = "playlists";
                        await manager.prepare();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Run(),
                          )
                        );
                      },
                    )
                ],
              );
            }
            else if (snapshot.hasError) {
              return Text('$snapshot.error');
            } else {
              return const CircularProgressIndicator();
            }
          }),
    ));
  }
}

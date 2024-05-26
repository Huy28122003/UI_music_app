import 'package:flutter/material.dart';
import 'package:ui_music_app/models/TrackManagement.dart';
TrackManangement manangement = TrackManangement();
class Test2 extends StatefulWidget {
  const Test2({super.key});

  @override
  State<Test2> createState() => _Test2State();
}

class _Test2State extends State<Test2> {
  @override
  Widget build(BuildContext context) {
    int id= ModalRoute.of(context)!.settings.arguments as int;
    manangement.currentTrack = id;
    manangement.playOrpause();
    if(manangement.isLoop == false){
      manangement.listenPlayComplete();
    }
    return SafeArea(child:  Scaffold(
      body: Column(
        children: [
          IconButton(
            icon: manangement.isPlaying ? Icon(Icons.pause) : Icon(Icons.play_arrow),
            onPressed: (){
              setState(() {
                manangement.isPlaying = !manangement.isPlaying;
              });
            },
          ),
          IconButton(
            icon: manangement.isLoop ? Icon(Icons.repeat_one_rounded) : Icon(Icons.repeat),
            onPressed: (){
              setState(() {
                manangement.isLoop = !manangement.isLoop;
                manangement.setPlayMode();
              });
            },
          ),
          // Slider(
          //     value: manangement.positon.inSeconds.toDouble(),
          //     onChanged: (value){
          //       setState(() {
          //
          //       });
          //     })
        ],
      ),
    ));
  }
}
import 'package:flutter/material.dart';
import 'package:ui_music_app/widgets/box.dart';
class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      appBar: AppBar(
        title: Text("Search"),
      ),
      body: Column(
        children: [
          NeuBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  child:  Image.asset("assets/images/profile.png"),
                  borderRadius: BorderRadius.circular(12),
                ),
              ],
            ),
          )
        ],
      ),

    ));
  }
}

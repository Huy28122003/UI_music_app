import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:music/screens/profile_edit.dart';
import 'package:music/screens/signIn.dart';
import 'package:music/screens/uploadSong.dart';
import 'package:music/widgets/bottom_navigation_bar.dart';
import 'package:music/widgets/verticalList.dart';
import 'library.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Profile"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: ListTile(
                  leading: Icon(Icons.music_note, color: Colors.blue),
                  title: const Text("Upload Song"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UploadScreen()),
                    );
                  },
                ),
              ),
              SizedBox(height: 10),
              Card(
                child: ListTile(
                  leading: Icon(Icons.favorite, color: Colors.red),
                  title: const Text("Favorites"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VerticalList(
                          name: "Favorites",
                          data: manager.dataFavorite,
                          location: "favorite",
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 10),
              Card(
                child: ListTile(
                  leading: Icon(Icons.edit, color: Colors.orange),
                  title: const Text("Edit Profile"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfileEdit()),
                    );
                  },
                ),
              ),
              SizedBox(height: 10),
              Card(
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.black),
                  title: const Text("Log out"),
                  onTap: () {
                    manager.audioPlayer.dispose();
                    manager.isSelected = false;
                    FirebaseAuth.instance.signOut();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/signIn',
                          (Route<dynamic> route) => false,
                    );
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

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:music/models/Song.dart';
import 'package:music/screens/profile_edit.dart';
import 'package:music/screens/uploadSong.dart';
import 'package:music/widgets/bottom_navigation_bar.dart';
import 'package:music/widgets/verticalList.dart';
import 'package:provider/provider.dart';

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
                  leading: const Icon(Icons.music_note, color: Colors.blue),
                  title: const Text("Upload Song"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UploadScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.favorite, color: Colors.red),
                  title: const Text("Favorites"),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => VerticalList(
                                name: "Favorites",
                                data:  Provider.of<SongProvider>(context, listen: false).favorite,
                                location: "favorite")));
                  },
                ),
              ),
              const SizedBox(height: 10),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.edit, color: Colors.orange),
                  title: const Text("Edit Profile"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfileEdit()),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.black),
                  title: const Text("Log out"),
                  onTap: () {
                    Provider.of<SongProvider>(context, listen: false).dispose();
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
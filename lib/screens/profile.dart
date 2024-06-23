import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:music/screens/gallery.dart';
import 'package:music/screens/profile_edit.dart';
import 'package:music/screens/signIn.dart';
import 'package:music/screens/uploadSong.dart';
import 'package:music/widgets/verticalList.dart';

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
      body: Column(
        children: [
          TextButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => UploadScreen()));
              },
              child: const Text("Song")),
          TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => VerticalList(
                            name: "Favorites",
                            data: manager.dataFavorite,
                            location: "favorite")));
              },
              child: const Text("Favorite")),
          TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfileEdit()));
              },
              child: const Text("Edit")),
          TextButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const SignIn()));
              },
              child: const Text("Log out"))
        ],
      ),
    ));
  }
}

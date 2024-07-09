import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:music/models/Song.dart';
import 'package:music/models/SongManager.dart';

class AutoLogin extends StatefulWidget {
  const AutoLogin({super.key});

  @override
  State<AutoLogin> createState() => _AutoLoginState();
}

class _AutoLoginState extends State<AutoLogin> {
  @override
  void initState() {
    super.initState();
    _checkAndLogin();
  }

  Future<void> _checkAndLogin() async {
    if (await _checkLoginStatus()) {
        Navigator.pushReplacementNamed(context, '/gallery');
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  Future<bool> _checkLoginStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    print(user?.uid);

    if (user != null) {
      return true;
    } else {
      return false;
    }
  }


  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

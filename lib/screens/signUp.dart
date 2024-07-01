import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:music/screens/gallery.dart';
import 'package:music/screens/library.dart';
import 'package:music/screens/signIn.dart';
import 'package:music/services/firebase_authen_service.dart';
import 'package:music/services/firebase_tracker_service.dart';

import '../models/Tracker.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final FirebaseAuthenService _authenService = FirebaseAuthenService();
  FirebaseTracker _firebaseTracker = FirebaseTracker();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool isSigning = false;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text("Sign up"),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  hintText: 'Username',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Colors.blue)),
                  hintStyle: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Email',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Colors.blue)),
                  hintStyle: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Colors.blue)),
                  hintStyle: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  _signUp();
                },
                child: isSigning
                    ? const CircularProgressIndicator()
                    : const Text("Confirm")),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account?"),
                TextButton(onPressed: (){
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => const SignIn()));
                }, child: const Text("Login"))
              ],
            )
          ],
        ),
      )
    ));
  }

  void _signUp() async {
    setState(() {
      isSigning = true;
    });
    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    User? user =
        await _authenService.signUpWithEmailAndPassword(context,email, password);
    _firebaseTracker.addUser(Tracker(user!.uid,"",0,"",[],[]));
    setState(() {
      isSigning = false;
    });
    if (user != null) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/library',
            (Route<dynamic> route) => false,
      );
    } else {
      print("Sing up is fail");
    }
  }
}

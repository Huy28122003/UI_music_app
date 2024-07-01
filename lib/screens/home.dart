import 'package:flutter/material.dart';
import 'package:music/screens/signIn.dart';
import 'package:music/services/firebase_authen_service.dart';
import 'package:music/services/firebase_push_notification_message_service.dart';
import './gallery.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    MessagingService().initNotification();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              Container(padding: const EdgeInsets.all(20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    "assets/images/img.png",
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 230,left: 40),
                child: const Text(
                  "Make your life \n"
                      "more interesting",
                  style: TextStyle(
                      fontSize: 25,
                      color: Colors.white
                  ),
                ),
              )
            ],
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => const SignIn()));
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                side: const BorderSide(color: Colors.deepOrange, width: 1)),
            child: const Text(
              "Continue with Email",
              style: TextStyle(fontSize: 20, color: Colors.deepOrange),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 20),
            child: const Text(
              "by continuing you agree to terms \n"
              "of services and  Privacy policy",
              style: TextStyle(color: Colors.grey),
            ),
          )
        ],
      ),
    ));
  }
}

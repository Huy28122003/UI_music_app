import 'package:flutter/material.dart';
import './test2.dart';
class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      body: Column(
        children: [
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Test2(),
                        settings: RouteSettings(arguments: 0)));
              },
              child: Icon(Icons.nat)),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Test2(),
                        settings: RouteSettings(arguments: 1)));
              },
              child: Icon(Icons.add)),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Test2(),
                        settings: RouteSettings(arguments: 2)));
              },
              child: Icon(Icons.add))
        ],
      ),
    ));
  }
}

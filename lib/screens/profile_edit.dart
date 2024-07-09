import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:music/models/Tracker.dart';
import 'package:music/services/firebase_tracker_service.dart';

class ProfileEdit extends StatefulWidget {
  const ProfileEdit({super.key});

  @override
  State<ProfileEdit> createState() => _ProfilleEditState();
}

class _ProfilleEditState extends State<ProfileEdit> {
  FirebaseTracker _firebaseTracker = FirebaseTracker();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  List<dynamic> _albums = [];
  List<dynamic> _likes = [];
  String? selectedOption;
  String? userId;
  List<String> options = [
    'Jazz',
    'Pop ',
    'Rock ',
    'Classical ',
    'Country ',
    'Red music'
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    User? user = FirebaseAuth.instance.currentUser;
    userId = user?.uid;
    _firebaseTracker.getUser(userId!).then((tracker) {
      setState(() {
        _nameController = TextEditingController(text: tracker?.name ?? '');
        _ageController =
            TextEditingController(text: tracker?.age.toString() ?? '');
        if(tracker!.favorite.isNotEmpty){
          selectedOption = tracker?.favorite;
        }
        _albums = tracker.album;
        _likes = tracker.likes;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: const Text("Edit"),
            ),
            body: SingleChildScrollView(
              child: FutureBuilder(
                  future: _firebaseTracker.getUser(userId!),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      Tracker tracker = snapshot.data!;
                      return Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey[200],
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide.none),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide:
                                        const BorderSide(color: Colors.blue)),
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.all(8.0),
                            child: TextField(
                              keyboardType: TextInputType.number,
                              controller: _ageController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey[200],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide:
                                      const BorderSide(color: Colors.blue),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.all(8.0),
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: "Favorite gerne",
                                border: OutlineInputBorder(),
                              ),
                              value: selectedOption,
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedOption = newValue;
                                });
                              },
                              items: options.map((String option) {
                                return DropdownMenuItem<String>(
                                  value: option,
                                  child: Text(option),
                                );
                              }).toList(),
                            ),
                          ),
                          ElevatedButton(
                              onPressed: () {
                                updateRequestToFirebase();
                              },
                              child: const Text("Confirm"))
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error ${snapshot.error}"));
                    } else {
                      return const CircularProgressIndicator();
                    }
                  }),
            )));
  }
  void updateRequestToFirebase() {
    try {
      String name = _nameController.text;
      String age = _ageController.text;
      String favorite = selectedOption!;
      Tracker tracker = Tracker(userId!, name, int.parse(age), favorite, _albums,_likes);
      print(tracker.id);
      print(tracker.name);
      print(tracker.age);
      print(tracker.favorite);
      print(tracker.album);
      print(tracker.likes);
      _firebaseTracker.updateUser(tracker);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Update is successful')),
      );
    } catch (e) {
      print("Co loi gi do $e");
    }
  }
}

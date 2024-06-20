import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:music/screens/gallery.dart';
import '../models/Tracker.dart';

class FirebaseTracker {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // get user from Firebase
  Future<Tracker?> getUser(String id) async {
    final doc = await _firestore.collection('users').doc(id).get();
    if (doc.exists) {
      return Tracker.fromMap(doc.data()!, id);
    }
    return null;
  }

  // add user to Firebase
    Future<void> addUser(Tracker tracker) async {
    await _firestore.collection('users').doc(tracker.id).set(tracker.toMap());
  }

  // update user in Firebase
  Future<void> updateUser(Tracker user) async {
    await _firestore.collection('users').doc(user.id).update(user.toMap());
  }

  // delete user from Firebase
  Future<void> deleteUser(Tracker user) async {
    await _firestore.collection('users').doc(user.id).delete();
  }

  // add song to album on firebase
  Future<void> addSongToAlbum(String songID,String userID) async {
    _firestore.collection("users").doc(userID).update({
      'album': FieldValue.arrayUnion([songID])
    });
  }

 Future<void> updateSongToLikes(String songID)async {
    String userID = FirebaseAuth.instance.currentUser!.uid;
    print(songID);
    print(userID);
    print(manager.isLike);
   try{
     if(manager.isLike){
       _firestore.collection("users").doc(userID).update({
         'likes': FieldValue.arrayUnion([songID])
       });
     }
     else{
       _firestore.collection("users").doc(userID).update({
         'likes': FieldValue.arrayRemove([songID])
       });
     }
   }catch(e){
     print("$e llllllllll");
   }

 }
}
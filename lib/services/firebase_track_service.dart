import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/FirebaseTrack.dart';
import '../screens/library.dart';

class FirebaseSong {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future<Song?> getSong(String sonID) async{
    final doc = await _firebaseFirestore.collection('playlists').doc(sonID).get();
    if (doc.exists) {
      Song song = Song.fromMap(doc.data()!);
      song.id = doc.id;
      return song;
    }
    return null;
  }

  Future<void> addSong(Song song,String id) async {
    await _firebaseFirestore.collection('playlists').doc(id).set(song.toMap());
  }

  Future<List<Song>> getSongsFromCollection(String collectionName) async {
    final collectionReference = _firebaseFirestore.collection(collectionName);
    final querySnapshot = await collectionReference.get();

    final List<Song> songs = [];
    for (final documentSnapshot in querySnapshot.docs) {
      final data = documentSnapshot.data();
      final song = Song.fromMap(data);
      song.id = documentSnapshot.id;
      songs.add(song);
    }
    return songs;
  }

  Future<void> updateToLikes(String songID) async {
    try {
      final documentReference = FirebaseFirestore.instance.collection('playlists').doc(songID);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(documentReference);
        int currentLikes = snapshot.get('likes') ?? 0;
        int newLikes;
        if(manager.isLike){
          newLikes = currentLikes + 1;
        }
        else{
          newLikes = currentLikes - 1;
        }
        transaction.update(documentReference, {'likes': newLikes});
      });
    } catch (e) {
      print('Lỗi  $e');
    }
  }
}
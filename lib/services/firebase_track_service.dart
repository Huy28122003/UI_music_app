import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:music/screens/gallery.dart';

import '../models/FirebaseTrack.dart';

class FirebaseSong {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

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

      // Giao dịch để đảm bảo tính nhất quán dữ liệu
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // Đọc giá trị hiện tại của trường 'likes'
        DocumentSnapshot snapshot = await transaction.get(documentReference);
        int currentLikes = snapshot.get('likes') ?? 0; // Nếu 'likes' không tồn tại, mặc định là 0
        // Cộng thêm 1 vào giá trị hiện tại
        int newLikes;
        if(manager.isLike){
          newLikes = currentLikes + 1;
        }
        else{
          newLikes = currentLikes - 1;
        }

        // Cập nhật tài liệu với giá trị mới
        transaction.update(documentReference, {'likes': newLikes});
      });
    } catch (e) {
      print('Lỗi  $e');
    }
  }
}
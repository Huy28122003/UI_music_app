import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:music/models/Tracker.dart';
import 'package:music/services/firebase_track_service.dart';
import 'package:music/services/firebase_tracker_service.dart';
import 'package:random_string/random_string.dart';

import '../models/FirebaseTrack.dart';

class UploadScreen extends StatefulWidget {
  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  XFile? _audioFile;
  XFile? _imageFile;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  FirebaseTracker _firebaseTracker = FirebaseTracker();
  TextEditingController _trackNameController = TextEditingController();
  FirebaseSong _song = FirebaseSong();
  bool _isImageSelected = false;
  bool _isAudioSelected = false;

  Future<void> _pickAudioFile() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickMedia();
    setState(() {
      _audioFile = pickedFile;
      _isAudioSelected = true;
    });
  }

  Future<void> _pickImageFile() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = pickedFile;
      _isImageSelected = true;
    });
  }

  Future<String> _uploadFile(
      XFile? file, String storagePath, String contentType) async {
    if (file == null) {
      return "";
    } else {
      try {
        setState(() {
          _isUploading = true;
        });

        final firebase_storage.Reference ref =
            firebase_storage.FirebaseStorage.instance.ref(storagePath);
        final metadata =
            firebase_storage.SettableMetadata(contentType: contentType);
        final uploadTask = ref.putFile(File(file.path), metadata);

        uploadTask.snapshotEvents.listen((snapshot) {
          setState(() {
            _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
          });
        });

        await uploadTask;
        final downloadURL = await ref.getDownloadURL();
        print('File đã được tải ên: $downloadURL');
        return downloadURL;
      } catch (e) {
        print('Lỗi khi tải lên file: $e');
      } finally {
        setState(() {
          _isUploading = false;
          _uploadProgress = 0.0;
        });
      }
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload my song'),
      ),
      body: Center(
          child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                _pickAudioFile();
              },
              child: const Text('Chọn file nhạc'),
            ),
            SizedBox(
              width: 100,
              height: 100,
              child: GestureDetector(
                child: (_isImageSelected)
                    ? Image.file(
                        File(_imageFile!.path),
                        fit: BoxFit.contain,
                      )
                    : Image.asset("assets/images/img4.png"),
                onTap: () {
                  _pickImageFile();
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.all(20.0),
              child: TextField(
                controller: _trackNameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_audioFile != null && _imageFile != null && !_isUploading) {
                  User? user = FirebaseAuth.instance.currentUser;
                  Tracker? tracker = await _firebaseTracker.getUser(user!.uid);
                  print(tracker?.name);
                  if (tracker?.name.length == 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Vui lòng cập nhật tên trong hồ sơ')),
                    );
                  } else if (_trackNameController.text.length == 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Vui lòng nhập đủ thông tin')),
                    );
                  } else {
                    String mp3Url = await _uploadFile(
                        _audioFile, 'mp3/${_audioFile!.name}', "audio/mpeg");
                    String imgUrl = await _uploadFile(
                        _imageFile, 'image/${_imageFile!.name}', "image/png");
                    String docId = randomAlphaNumeric(20);
                    Song song = Song(
                        user.uid,
                        _trackNameController.text.toString(),
                        imgUrl,
                        mp3Url,
                        0);
                    _song.addSong(song, docId);
                    try {
                      _firebaseTracker.addSongToAlbum(docId, user.uid);
                    } catch (e) {
                      print(e);
                    }
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Chưa đủ thông tin")),
                  );
                }
              },
              child: const Text('Confirm'),
            ),
            if (_isUploading)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: LinearProgressIndicator(value: _uploadProgress),
              ),
          ],
        ),
      )),
    );
  }
}

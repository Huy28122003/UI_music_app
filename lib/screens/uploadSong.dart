import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:music/models/Song.dart';
import 'package:music/models/Tracker.dart';
import 'package:music/services/firebase_track_service.dart';
import 'package:music/services/firebase_tracker_service.dart';
import 'package:music/services/httpv1_send_messaging_service.dart';
import 'package:provider/provider.dart';
import 'package:random_string/random_string.dart';
import '../models/FirebaseTrack.dart';

class UploadScreen extends StatefulWidget {
  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  FirebaseSong _firebaseSong = FirebaseSong();
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
    if (pickedFile != null) {
      setState(() {
        _audioFile = pickedFile;
        _isAudioSelected = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Audio file selected: ${pickedFile.name}')),
      );
    }
  }

  Future<void> _pickImageFile() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
        _isImageSelected = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image file selected: ${pickedFile.name}')),
      );
    }
  }

  Future<String> _uploadFile(
      XFile? file, String storagePath, String contentType) async {
    if (file == null) return "";

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File uploaded: $downloadURL')),
      );
      return downloadURL;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading file: $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload My Song'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        color: Colors.deepPurple.shade50,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _pickAudioFile,
                  style: ElevatedButton.styleFrom(
                    primary: Colors.deepPurple,
                    onPrimary: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: const Text('Select Audio File'),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _pickImageFile,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12.0),
                      image: _isImageSelected
                          ? DecorationImage(
                              image: FileImage(File(_imageFile!.path)),
                              fit: BoxFit.cover,
                            )
                          : const DecorationImage(
                              image: AssetImage("assets/images/img4.png"),
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _trackNameController,
                  decoration: InputDecoration(
                    labelText: 'Track Name',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(color: Colors.deepPurple),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_audioFile != null &&
                        _imageFile != null &&
                        !_isUploading) {
                      User? user = FirebaseAuth.instance.currentUser;
                      Tracker? tracker =
                          await _firebaseTracker.getUser(user!.uid);

                      if (tracker?.name.isEmpty ?? true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please update your profile name')),
                        );
                      } else if (_trackNameController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please enter track name')),
                        );
                      } else {
                        String mp3Url = await _uploadFile(_audioFile,
                            'mp3/${_audioFile!.name}', "audio/mpeg");
                        String imgUrl = await _uploadFile(_imageFile,
                            'image/${_imageFile!.name}', "image/png");
                        String docId = randomAlphaNumeric(20);
                        Song song = Song(user.uid, _trackNameController.text,
                            imgUrl, mp3Url, 0,Timestamp.fromDate(DateTime.now()));
                        _song.addSong(song, docId);
                        try {
                          _firebaseTracker.addSongToAlbum(docId, user.uid);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Song uploaded successfully')),
                          );

                          HTTPv1Service().sendFCMMessage(
                              "A new interesting song",
                              _trackNameController.text.toString(),
                              docId);
                          Provider.of<SongProvider>(context, listen: false).setDataSource("playlist");
                          await Provider.of<SongProvider>(context, listen: false).loadData("playlist");
                          Provider.of<SongProvider>(context, listen: false).getDataWithPosition();

                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/gallery',
                            (Route<dynamic> route) => false,
                          );
                        } catch (e) {
                          print(e);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Error adding song to album: $e')),
                          );
                        }
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Incomplete information')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: const Text('Confirm'),
                ),
                if (_isUploading)
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        LinearProgressIndicator(
                          value: _uploadProgress,
                          backgroundColor: Colors.deepPurple.shade100,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.deepPurple),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${(_uploadProgress * 100).toStringAsFixed(2)}% uploaded',
                          style: const TextStyle(color: Colors.deepPurple),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

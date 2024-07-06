import 'package:cloud_firestore/cloud_firestore.dart';

class Song {
  String  _id= "";
  String _authorID;
  String _name;
  String _imgUrl;
  String _mp3Url;
  int _likes;
  Timestamp? _createdOn;

  Song(this._authorID, this._name, this._imgUrl, this._mp3Url, this._likes,this._createdOn);

  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(map['authorID'], map['name'], map['imgUrl'],
        map['mp3Url'],map['likes'],map['createdOn']);
  }

  Map<String, dynamic> toMap() {
    return {
      'authorID': _authorID,
      'name': _name,
      'likes': _likes,
      'imgUrl': _imgUrl,
      'mp3Url': _mp3Url,
      'createdOn': _createdOn
    };
  }

  Timestamp get createdOn => _createdOn!;

  set createdOn(Timestamp value) {
    _createdOn = value;
  }

  String get id => _id;

  set id(String value) {
    _id = value;
  }

  int get likes => _likes;

  set likes(int value) {
    _likes = value;
  }

  String get mp3Url => _mp3Url;

  set mp3Url(String value) {
    _mp3Url = value;
  }

  String get imgUrl => _imgUrl;

  set imgUrl(String value) {
    _imgUrl = value;
  }

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  String get authorID => _authorID;

  set authorID(String value) {
    _authorID = value;
  }
}

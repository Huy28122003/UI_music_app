class Tracker {
  String _id;
  String _name;
  int _age;
  String _favorite;
  List<dynamic> _album;
  List<dynamic> _likes;
  String _fcmToken = "";

  Tracker(this._id, this._name, this._age, this._favorite, this._album,
      this._likes);

  String get id => _id;

  set id(String value) {
    _id = value;
  }

  factory Tracker.fromMap(Map<String, dynamic> map, String userId) {
    return Tracker(
      userId,
      map['name'] as String,
      map['age'] as int,
      map['favorite'] as String,
      map['album'] as List<dynamic>,
      map['likes'] as List<dynamic>,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': _name,
      'age': _age,
      'favorite': _favorite,
      'album': _album,
      'likes': _likes
    };
  }

  List<dynamic> get likes => _likes;

  set likes(List<dynamic> value) {
    _likes = value;
  }

  List<dynamic> get album => _album;

  set album(List<dynamic> value) {
    _album = value;
  }

  String get favorite => _favorite;

  set favorite(String value) {
    _favorite = value;
  }

  int get age => _age;

  set age(int value) {
    _age = value;
  }

  String get name => _name;

  set name(String value) {
    _name = value;
  }
}

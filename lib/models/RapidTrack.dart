class Track {
  String _name;
  String _mp3Url;
  String _imgUrl;

  Track(this._name, this._mp3Url, this._imgUrl);

  LocalTrack(String name, String previewUrl) {
    _name = name;
    _mp3Url = previewUrl;
  }

  String get imgUrl => _imgUrl;

  set imgUrl(String value) {
    _imgUrl = value;
  }

  String get preview_url => _mp3Url;

  set preview_url(String value) {
    _mp3Url = value;
  }

  String get name => _name;

  set name(String value) {
    _name = value;
  }
}
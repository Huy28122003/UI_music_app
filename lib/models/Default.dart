import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DeviceStoragePath {
  static final DeviceStoragePath _instance = DeviceStoragePath._internal();

  factory DeviceStoragePath() {
    return _instance;
  }

  DeviceStoragePath._internal();

  String? _path;

  Future<String> getPath() async {
    if (_path == null) {
      final status = await Permission.storage.request();
      if (status.isGranted) {
        final baseStorage = await getExternalStorageDirectory();
        _path = baseStorage!.path;
      } else {
        _path = "";
      }
    }
    return _path!;
  }
}

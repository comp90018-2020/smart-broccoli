import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

/// Local picture storage utility
class PictureStash {
  final String _baseDir;

  /// Constructor for internal use only
  PictureStash._internal(this._baseDir);

  /// Constructor for external use
  static Future<PictureStash> create() async =>
      PictureStash._internal((await getTemporaryDirectory()).path);

  /// Retrieve a picture with specified [id] from local storage.
  ///
  /// If the picture does not exist, return null.
  Future<String> getPic(int id) async {
    String assetDir = '$_baseDir/picture/$id';
    if (await File(assetDir).exists()) {
      return assetDir;
    }
    return null;
  }

  /// Save a picture with specified [id] to local storage.
  Future<void> storePic(int id, Uint8List bytes) async {
    // ensure picture directory exists
    final Directory picDir =
        await Directory('$_baseDir/picture').create(recursive: true);
    // then store the asset
    String assetDir = '${picDir.path}/$id';
    try {
      File f = File(assetDir);
      f.writeAsBytes(bytes);
    } catch (_) {}
  }

  /// Clear all pictures from local storage.
  Future<void> clear() async {
    var directory = Directory('$_baseDir/picture');
    if (await directory.exists()) await directory.delete(recursive: true);
  }
}

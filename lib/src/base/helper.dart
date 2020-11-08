import 'dart:io';

import 'package:image/image.dart' as img;

/// Loads the file and bakes the EXIF orientation into the file
Future<List<int>> loadFileAndBakeOrientation(String path) async {
  try {
    img.Image captured = img.decodeImage(await File(path).readAsBytes());
    img.Image baked = img.bakeOrientation(captured);
    return img.encodePng(baked);
  } catch (e) {
    return Future.error(e);
  }
}

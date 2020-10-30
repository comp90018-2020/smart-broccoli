import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();

  return directory.path;
}


Future<File> get _localFile async {
  final path = await _localPath;
  return File('$path/backgroundData.txt');
}


Future<File> writeBackgroundData(String data) async {
  final file = await _localFile;

  // Write the file.
  return file.writeAsString('$data');
}

Future<List<String>> readBackground() async {
  try {
    final file = await _localFile;

    // Read the file.
    String contents = await file.readAsString();

    return contents.split(",");
  } catch (e) {
    // If encountering an error, return 0.
    return null;
  }
}


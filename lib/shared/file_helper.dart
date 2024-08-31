import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart' as mime;
import 'package:path/path.dart' as path;
import 'package:universal_io/io.dart';

class FileHelper {
  FileHelper._();

  static Future<bool> ensureDirectoryExists(String filepath) async {
    Directory dir = Directory(path.dirname(filepath));

    try {
      if (!await dir.exists()) await dir.create(recursive: true);
    } catch (e) {
      return false;
    }

    return true;
  }

  static MediaType? parseMediaType(PlatformFile file) {
    final mimeType = mime.lookupMimeType(file.path!);
    return mimeType != null ? MediaType.parse(mimeType) : null;
  }

  static bool isFilePicked(PlatformFile file) {
    final streamData = file.readStream;
    final filePath = file.path;

    return (filePath == null || streamData == null) ? false : true;
  }
}
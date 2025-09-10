import 'package:path/path.dart' as p;

class VideoNameHelper {
  static String extractDisplayName(String path) {
    final fileName = p.basename(path);
    return fileName.contains("edited_video_")
        ? fileName.split("edited_video_").last
        : fileName;
  }
}

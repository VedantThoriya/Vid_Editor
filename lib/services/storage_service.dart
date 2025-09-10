import 'dart:io';
import 'package:hive/hive.dart';

class StorageService {
  static const String videoBoxName = 'videos';
  static late Box<String> _box;
  static late Directory _baseDir;

  /// Initialize Hive and open box
  static Future<void> init({required String baseDir}) async {
    _baseDir = Directory(baseDir);
    Hive.init(baseDir);
    _box = await Hive.openBox<String>(videoBoxName);

    // Ensure VideoEdits folder exists inside baseDir
    final customDir = await getCustomVideoDir();
    if (!await customDir.exists()) {
      await customDir.create(recursive: true);
    }
  }

  /// Get custom folder for storing videos
  static Future<Directory> getCustomVideoDir() async {
    // Store videos in app's Documents directory
    final customDir = Directory('${_baseDir.path}/VideoEdits');
    return customDir;
  }

  /// Save edited video to custom folder and store path in Hive
  static Future<String> saveVideoFile(File video) async {
    final customDir = await getCustomVideoDir();
    final newPath =
        '${customDir.path}/edited_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
    final newVideo = await video.copy(newPath);

    await _box.add(newVideo.path);
    return newVideo.path;
  }

  /// Get all saved video paths
  static List<String> getAllVideos() {
    return _box.values.toList();
  }

  /// Delete video by index (also deletes the actual file)
  static Future<void> deleteVideoAt(int index) async {
    if (index >= 0 && index < _box.length) {
      final path = _box.getAt(index);
      if (path != null && await File(path).exists()) {
        await File(path).delete();
      }
      await _box.deleteAt(index);
    }
  }
}

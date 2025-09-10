import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';

class VideoProcessingService {
  /// Export video with brightness, contrast, rotation, trim
  static Future<String> exportEditedVideo({
    required String inputPath,
    required double brightness,
    required double contrast,
    required int rotate,
    required Duration startTrim,
    required Duration endTrim,
    required Duration totalDuration,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final saveDir = Directory("${dir.path}/VidEditor");
    if (!await saveDir.exists()) await saveDir.create(recursive: true);

    final outputPath =
        '${saveDir.path}/edited_video_${DateTime.now().millisecondsSinceEpoch}.mp4';

    double startSeconds = startTrim.inMilliseconds / 1000.0;
    double durationSeconds =
        (endTrim.inMilliseconds - startTrim.inMilliseconds) / 1000.0;

    if (durationSeconds <= 0) {
      durationSeconds = totalDuration.inSeconds.toDouble();
    }

    // Filters
    final filters = <String>[
      'eq=brightness=${brightness - 1.0}:contrast=$contrast'
    ];

    if (rotate != 0) {
      if (rotate == 90) {
        filters.add('transpose=1');
      } else if (rotate == -90 || rotate == 270) {
        filters.add('transpose=2');
      } else if (rotate == 180) {
        filters.add('transpose=1,transpose=1');
      }
    }

    final filterChain = filters.join(',');

    final cmd =
        '-ss $startSeconds -t $durationSeconds -i "$inputPath" '
        '-vf "$filterChain" -c:v libx264 -c:a aac -preset ultrafast "$outputPath"';

    final session = await FFmpegKit.execute(cmd);
    final returnCode = await session.getReturnCode();

    if (!ReturnCode.isSuccess(returnCode)) {
      final logs = await session.getAllLogs();
      throw Exception("FFmpeg failed: $logs");
    }

    return outputPath;
  }
}

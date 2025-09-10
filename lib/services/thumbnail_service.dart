import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoThumbnailService {
  /// Generate a video thumbnail
  static Future<ImageProvider> getThumbnail(String path) async {
    try {
      final uint8list = await VideoThumbnail.thumbnailData(
        video: path,
        imageFormat: ImageFormat.PNG,
        maxWidth: 200,
        quality: 75,
      );
      if (uint8list != null) {
        return MemoryImage(uint8list);
      }
    } catch (_) {}
    return const AssetImage('assets/video_placeholder.png');
  }
}

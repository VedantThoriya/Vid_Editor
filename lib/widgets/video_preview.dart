import 'package:flutter/material.dart';
import 'package:vid_editor/screens/preview.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoPreviewWidget extends StatelessWidget {
  final String videoPath;
  const VideoPreviewWidget({super.key, required this.videoPath});

  Future<ImageProvider?> _getThumbnail(String path) async {
    try {
      final uint8list = await VideoThumbnail.thumbnailData(
        video: path,
        imageFormat: ImageFormat.PNG,
        maxWidth: 400,
        quality: 75,
      );
      if (uint8list != null) return MemoryImage(uint8list);
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ImageProvider?>(
      future: _getThumbnail(videoPath),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) {
          return const SizedBox(); // hide if no thumbnail
        }

        return AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Thumbnail background
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.0),
                  image: DecorationImage(
                    image: snapshot.data!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Play overlay
              Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PreviewScreen(videoPath: videoPath),
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

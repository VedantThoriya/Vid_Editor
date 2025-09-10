import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vid_editor/helpers/video_name_helper.dart';
import 'package:vid_editor/screens/preview.dart';
import 'package:vid_editor/services/thumbnail_service.dart';

class VideoListItem extends StatelessWidget {
  final String path;
  final int index;
  final VoidCallback onDelete;

  const VideoListItem({
    super.key,
    required this.path,
    required this.index,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = VideoNameHelper.extractDisplayName(path);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail with play overlay
          FutureBuilder<ImageProvider>(
            future: VideoThumbnailService.getThumbnail(path),
            builder: (context, snapshot) {
              final img =
                  snapshot.data ??
                  const AssetImage('assets/video_placeholder.png');

              return Stack(
                children: [
                  Container(
                    width: 120,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(image: img, fit: BoxFit.cover),
                    ),
                  ),
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PreviewScreen(videoPath: path),
                            ),
                          );
                        },
                        child: const Center(
                          child: Icon(
                            Icons.play_circle_fill,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(width: 12),

          // Right side info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Video ${index + 1}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.blue),
                      onPressed: () async {
                        final file = File(path);
                        if (await file.exists()) {
                          await Share.shareXFiles([
                            XFile(file.path),
                          ], text: "Check out my video!");
                        } else {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Video not found")),
                          );
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

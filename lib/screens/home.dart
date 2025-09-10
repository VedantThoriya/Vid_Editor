import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:vid_editor/screens/edit_video.dart';
import 'package:vid_editor/services/storage_service.dart';
import 'package:vid_editor/widgets/navbar.dart';
import '../widgets/welcome_card.dart';
import '../widgets/data_card.dart';
import '../widgets/video_preview.dart';

class VideoEditsHomePage extends StatefulWidget {
  const VideoEditsHomePage({super.key});

  @override
  State<VideoEditsHomePage> createState() => _VideoEditsHomePageState();
}

class _VideoEditsHomePageState extends State<VideoEditsHomePage> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickVideo(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
      );

      if (result != null && result.files.isNotEmpty) {
        final String? videoPath = result.files.first.path;
        if (videoPath != null) {
          if (!context.mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VideoEditorPage(videoPath: videoPath),
            ),
          );
        } else {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Selected video path is invalid.')),
          );
        }
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No video selected.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking video: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final videos = StorageService.getAllVideos();
    final lastVideo = videos.isNotEmpty ? videos.last : null;
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFEDE7F6),
            ),
            child: const Padding(
              padding: EdgeInsets.all(6.0),
              child: Icon(
                Icons.videocam_outlined,
                size: 24,
                color: Colors.deepPurple,
              ),
            ),
          ),
        ),
        title: const Text(
          "VidEditor",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WelcomeSection(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  DataCardWidget(
                    value: videos.length.toString(),
                    label: 'Videos Created',
                    icon: Icons.play_arrow,
                    iconColor: Colors.teal.shade400,
                    backgroundColor: Colors.white,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Show preview only if last video exists
            if (lastVideo != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 20.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Recent Edits",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    VideoPreviewWidget(videoPath: lastVideo),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.0),
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple.shade400, Colors.blue.shade400],
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                  ),
                ),
                child: TextButton.icon(
                  onPressed: () => _pickVideo(context),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    "Pick a Video",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }
}

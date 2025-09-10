import 'package:flutter/material.dart';
import 'package:vid_editor/services/storage_service.dart';
import 'package:vid_editor/widgets/navbar.dart';
import 'package:vid_editor/widgets/video_list_item.dart';

class CreationsPage extends StatefulWidget {
  const CreationsPage({super.key});

  @override
  State<CreationsPage> createState() => _CreationsPageState();
}

class _CreationsPageState extends State<CreationsPage> {
  late List<String> videos;

  @override
  void initState() {
    super.initState();
    videos = StorageService.getAllVideos();
  }

  Future<void> _deleteVideo(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Video"),
        content: const Text("Are you sure you want to delete this video?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await StorageService.deleteVideoAt(index);
      setState(() => videos = StorageService.getAllVideos());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Video deleted successfully")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
          "My Creations",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: videos.isEmpty
          ? const Center(child: Text("No saved videos yet"))
          : ListView.builder(
              itemCount: videos.length,
              itemBuilder: (context, index) {
                final path = videos[index];
                return VideoListItem(
                  path: path,
                  index: index,
                  onDelete: () => _deleteVideo(index),
                );
              },
            ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }
}

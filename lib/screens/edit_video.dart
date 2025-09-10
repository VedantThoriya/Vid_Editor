import 'dart:io';
import 'package:flutter/material.dart';
import 'package:vid_editor/services/video_service.dart';
import 'package:vid_editor/utils/duration_extensions.dart';
import 'package:video_player/video_player.dart';
import 'package:vid_editor/services/storage_service.dart';
import 'package:vid_editor/screens/preview.dart';

class VideoEditorPage extends StatefulWidget {
  final String videoPath;
  const VideoEditorPage({super.key, required this.videoPath});

  @override
  State<VideoEditorPage> createState() => _VideoEditorPageState();
}

class _VideoEditorPageState extends State<VideoEditorPage>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _controller;
  late TabController _tabController;

  double brightness = 1.0;
  double contrast = 1.0;
  int rotate = 0;
  Duration startTrim = Duration.zero;
  Duration endTrim = Duration.zero;

  late bool _isSeeking;

  @override
  void initState() {
    super.initState();
    _isSeeking = false;

    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() => endTrim = _controller.value.duration);
        _controller.play();
      });

    // loop playback between trims
    _controller.addListener(() {
      if (!_controller.value.isPlaying) return;
      if (!_isSeeking && _controller.value.position >= endTrim) {
        _isSeeking = true;
        _controller.seekTo(startTrim).then((_) {
          _controller.play();
          _isSeeking = false;
        });
      }
    });

    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _saveVideo() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final exportedPath = await VideoProcessingService.exportEditedVideo(
        inputPath: widget.videoPath,
        brightness: brightness,
        contrast: contrast,
        rotate: rotate,
        startTrim: startTrim,
        endTrim: endTrim,
        totalDuration: _controller.value.duration,
      );

      final savedPath = await StorageService.saveVideoFile(File(exportedPath));

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("✅ Video saved at $savedPath")));
      Navigator.pushReplacementNamed(context, '/creations');
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("❌ Failed: $e")));
      }
    }
  }

  Future<void> _previewVideo() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final exportedPath = await VideoProcessingService.exportEditedVideo(
        inputPath: widget.videoPath,
        brightness: brightness,
        contrast: contrast,
        rotate: rotate,
        startTrim: startTrim,
        endTrim: endTrim,
        totalDuration: _controller.value.duration,
      );
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PreviewScreen(videoPath: exportedPath),
        ),
      );
    } catch (_) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Preview generation failed")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Video"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                brightness = 1.0;
                contrast = 1.0;
                rotate = 0;
                startTrim = Duration.zero;
                endTrim = _controller.value.duration;
                _controller.seekTo(startTrim);
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Preview card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
              child: SizedBox(
                height: screenHeight * 0.45,
                width: double.infinity,
                child: _controller.value.isInitialized
                    ? FittedBox(
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: _controller.value.size.width,
                          height: _controller.value.size.height,
                          child: Transform.rotate(
                            angle: rotate * 3.14159 / 180,
                            child: VideoPlayer(_controller),
                          ),
                        ),
                      )
                    : const Center(child: CircularProgressIndicator()),
              ),
            ),

            // 🗂abs
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Trim & Rotate'),
                Tab(text: 'Effects'),
              ],
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // ✂️ Trim & Rotate
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.play_arrow, size: 16),
                                const SizedBox(width: 4),
                                Text(startTrim.formatAsMMSS()),
                              ],
                            ),
                            Row(
                              children: [
                                Text(endTrim.formatAsMMSS()),
                                const SizedBox(width: 4),
                                const Icon(Icons.stop, size: 16),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        RangeSlider(
                          values: RangeValues(
                            startTrim.inSeconds.toDouble(),
                            endTrim.inSeconds.toDouble(),
                          ),
                          min: 0,
                          max: _controller.value.duration.inSeconds.toDouble(),
                          onChanged: (range) {
                            setState(() {
                              startTrim = Duration(
                                seconds: range.start.toInt(),
                              );
                              endTrim = Duration(seconds: range.end.toInt());
                              _controller.seekTo(startTrim);
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        const Text("Rotate Video"),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () =>
                                  setState(() => rotate = (rotate - 90) % 360),
                              icon: const Icon(Icons.rotate_left, size: 32),
                            ),
                            IconButton(
                              onPressed: () =>
                                  setState(() => rotate = (rotate + 90) % 360),
                              icon: const Icon(Icons.rotate_right, size: 32),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 🎨 Effects
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.wb_sunny_outlined),
                            SizedBox(width: 8),
                            Text("Brightness"),
                          ],
                        ),
                        Slider(
                          value: brightness,
                          min: 0.0,
                          max: 2.0,
                          divisions: 20,
                          onChanged: (val) => setState(() => brightness = val),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: const [
                            Icon(Icons.tonality_outlined),
                            SizedBox(width: 8),
                            Text("Contrast"),
                          ],
                        ),
                        Slider(
                          value: contrast,
                          min: 0.0,
                          max: 4.0,
                          divisions: 40,
                          onChanged: (val) => setState(() => contrast = val),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Save & Preview buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _saveVideo,
                      icon: const Icon(Icons.save),
                      label: const Text('Save'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _previewVideo,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Preview'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

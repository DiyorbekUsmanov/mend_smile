import 'package:flutter/material.dart';
import 'package:mend_smile/utils/AppColors.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerPage extends StatefulWidget {
  final String title;
  final String videoPath;
  final String description;
  final bool isAlreadyDone;

  const VideoPlayerPage({
    super.key,
    required this.title,
    required this.videoPath,
    required this.description,
    required this.isAlreadyDone,
  });

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoPath);
    _controller.initialize().then((_) {
      setState(() {
        _initialized = true;
        _isPlaying = true;
        _controller.play();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      _isPlaying ? _controller.play() : _controller.pause();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _initialized
                ? GestureDetector(
              onTap: _togglePlayPause,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                  if (!_isPlaying)
                    const Icon(Icons.play_circle_fill,
                        size: 64, color: Colors.white70),
                ],
              ),
            )
                : const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  widget.description,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.justify,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _initialized
          ? FloatingActionButton.extended(
        onPressed: widget.isAlreadyDone
            ? null
            : () {
          Navigator.pop(context, true); // Mark as done
        },
        backgroundColor:
        widget.isAlreadyDone ? Colors.lightGreen : AppColors().primary,
        icon: Icon(
          widget.isAlreadyDone ? Icons.check_circle : Icons.check,
        ),
        label: Text(widget.isAlreadyDone
            ? 'You’ve done this today'
            : 'Done'),
      )
          : null,
    );
  }
}

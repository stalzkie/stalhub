// loading_video_screen.dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class LoadingVideoScreen extends StatefulWidget {
  final VoidCallback onVideoEnd;

  const LoadingVideoScreen({super.key, required this.onVideoEnd});

  @override
  State<LoadingVideoScreen> createState() => _LoadingVideoScreenState();
}

class _LoadingVideoScreenState extends State<LoadingVideoScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/loading.mp4')
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });

    _controller.addListener(() {
      if (_controller.value.position == _controller.value.duration) {
        widget.onVideoEnd();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}

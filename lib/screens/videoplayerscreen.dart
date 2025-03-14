import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class SimpleVideoPlayerScreen extends StatefulWidget {
  final String videoPath;
  final String nextRoute; 

  const SimpleVideoPlayerScreen({super.key, required this.videoPath, required this.nextRoute});

  @override
  _SimpleVideoPlayerScreenState createState() => _SimpleVideoPlayerScreenState();
}

class _SimpleVideoPlayerScreenState extends State<SimpleVideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool isVideoCompleted = false;

  @override
  void initState() {
    super.initState();

    print("Trying to load: ${widget.videoPath}");

    _controller = VideoPlayerController.asset(widget.videoPath)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      }).catchError((error) {
        print("Video load error: $error");
      });

    
    _controller.addListener(() {
      if (_controller.value.position >= _controller.value.duration) {
        if (!isVideoCompleted) {
          setState(() {
            isVideoCompleted = true;
          });

          
          Future.delayed(const Duration(seconds: 1), () {
            Navigator.pushReplacementNamed(context, widget.nextRoute);
          });
        }
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
      appBar: AppBar(title: const Text("Watch Video")),
      body: Stack(
        children:[
          Center(
          child: _controller.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              : const CircularProgressIndicator(),
        ),
        Positioned(
          top: 40,
          right: 20,
          child: ElevatedButton(
            onPressed: (){
          Navigator.pushReplacementNamed(context, widget.nextRoute);
        }, 
        child: const Text("Skip")
        )
        )

        ] 
      ),
      
    );
  }
}

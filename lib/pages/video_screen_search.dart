import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoScreenSearch extends StatefulWidget {
  final String vidName;

  VideoScreenSearch(this.vidName);

  @override
  VideoScreenSearchState createState() => VideoScreenSearchState();
}

class VideoScreenSearchState extends State<VideoScreenSearch> with TickerProviderStateMixin {
  late CustomVideoPlayerController _customVideoPlayerController;
  late VideoPlayerController _videoPlayerController;
  late AnimationController _overlayAnimationController;
  late Animation<double> _fadeAnimation;

  bool isLoading = true;
  bool isPlaying = false;
  bool showPlayPauseOverlay = false;

  @override
  void initState() {
    super.initState();
    initializeVideoPlayer();
    _overlayAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _overlayAnimationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _videoPlayerController.removeListener(videoStatusListener);
    _videoPlayerController.dispose();
    _customVideoPlayerController.dispose();
    _overlayAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: Colors.black,
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      )
          : GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          togglePlayPause();
          setState(() {
            showPlayPauseOverlay = true;
          });
          _overlayAnimationController.forward(from: 0.0);
          Future.delayed(Duration(seconds: 2), () {
            _overlayAnimationController.reverse();
          });
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomVideoPlayer(
              customVideoPlayerController: _customVideoPlayerController,
            ),
            FadeTransition(
              opacity: _fadeAnimation,
              child: Icon(
                isPlaying
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_filled,
                color: Colors.white.withOpacity(0.8),
                size: 100,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void initializeVideoPlayer() {
    String videoUrl = widget.vidName;

    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoUrl))
      ..initialize().then((_) {
        setState(() {
          isLoading = false;
          isPlaying = _videoPlayerController.value.isPlaying;
        });
        _videoPlayerController.addListener(videoStatusListener);
      }).catchError((error) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading video: $error')),
        );
      });

    _customVideoPlayerController = CustomVideoPlayerController(
      context: context,
      videoPlayerController: _videoPlayerController,
      customVideoPlayerSettings: CustomVideoPlayerSettings(
        exitFullscreenOnEnd: true,
      ),
    );
  }

  void videoStatusListener() {
    setState(() {
      isPlaying = _videoPlayerController.value.isPlaying;
    });
  }

  void togglePlayPause() {
    if (_videoPlayerController.value.isPlaying) {
      _videoPlayerController.pause();
    } else {
      _videoPlayerController.play();
    }
  }
}

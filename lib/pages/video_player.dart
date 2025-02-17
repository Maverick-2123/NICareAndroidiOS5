import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoScreen extends StatefulWidget {
  final String vidName;

  VideoScreen(this.vidName);

  @override
  VideoScreenState createState() => VideoScreenState();
}

class VideoScreenState extends State<VideoScreen> with TickerProviderStateMixin {
  late CustomVideoPlayerController _customVideoPlayerController;
  late VideoPlayerController _videoPlayerController;
  late AnimationController _overlayAnimationController;
  late AnimationController _commentSheetController;
  late Animation<double> _fadeAnimation;

  bool isLoading = true;
  bool isPlaying = false;
  bool showPlayPauseOverlay = false;
  bool isLiked = false;
  bool isDisliked = false;
  bool showComments = false;

  final TextEditingController _commentController = TextEditingController();
  final List<String> comments = []; // Store comments

  @override
  void initState() {
    super.initState();
    initializeVideoPlayer();
    _setupAnimationControllers();
    _overlayAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
  }

  void _setupAnimationControllers() {
    _overlayAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _overlayAnimationController,
      curve: Curves.easeInOut,
    );
    _commentSheetController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _videoPlayerController.removeListener(videoStatusListener);
    _videoPlayerController.dispose();
    _customVideoPlayerController.dispose();
    _overlayAnimationController.dispose();
    _commentSheetController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _handleLike() {
    setState(() {
      if (isDisliked) isDisliked = false;
      isLiked = !isLiked;
    });
  }

  void _handleDislike() {
    setState(() {
      if (isLiked) isLiked = false;
      isDisliked = !isDisliked;
    });
  }

  void _showCommentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CommentSheet(
        comments: comments,
        onCommentSubmitted: (comment) {
          setState(() {
            comments.add(comment);
          });
        },
      ),
    );
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
          ? Center(child: CircularProgressIndicator(color: Colors.white))
          : Stack(
        children: [
          // Video Player with Tap Gesture
          GestureDetector(
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
                    isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                    color: Colors.white.withOpacity(0.8),
                    size: 100,
                  ),
                ),
              ],
            ),
          ),

          // Social Interaction Buttons
          Positioned(
            right: 16,
            bottom: MediaQuery.of(context).size.height * 0.2,
            child: Column(
              children: [
                _SocialButton(
                  icon: isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                  onTap: _handleLike,
                  isActive: isLiked,
                ),
                SizedBox(height: 16),
                _SocialButton(
                  icon: isDisliked ? Icons.thumb_down : Icons.thumb_down_outlined,
                  onTap: _handleDislike,
                  isActive: isDisliked,
                ),
                SizedBox(height: 16),
                _SocialButton(
                  icon: Icons.comment_outlined,
                  onTap: _showCommentSheet,
                  isActive: false,
                  badge: comments.isNotEmpty ? '${comments.length}' : null,
                ),
              ],
            ),
          ),
        ],
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

    // Initialize the custom video player controller
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
class _SocialButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;
  final String? badge;

  const _SocialButton({
    required this.icon,
    required this.onTap,
    this.isActive = false,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(
              icon,
              color: isActive ? Colors.blue : Colors.white,
              size: 24,
            ),
            onPressed: onTap,
          ),
        ),
        if (badge != null)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                badge!,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// Comment Sheet Widget
class _CommentSheet extends StatefulWidget {
  final List<String> comments;
  final Function(String) onCommentSubmitted;

  const _CommentSheet({
    required this.comments,
    required this.onCommentSubmitted,
  });

  @override
  _CommentSheetState createState() => _CommentSheetState();
}

class _CommentSheetState extends State<_CommentSheet> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Comments list
          Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: widget.comments.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(widget.comments[index]),
                );
              },
            ),
          ),

          // Comment input
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (_commentController.text.isNotEmpty) {
                      widget.onCommentSubmitted(_commentController.text);
                      _commentController.clear();
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


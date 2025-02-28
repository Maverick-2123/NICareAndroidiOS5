import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:video_player/video_player.dart';
import 'global.dart' as global;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:nicare/pages/team_page.dart';

class VideoScreenReels extends StatefulWidget {
  final String vidName;
  final String vidUrl;
  final int vidId;

  const VideoScreenReels(this.vidName, this.vidUrl, {this.vidId = 0, Key? key})
      : super(key: key);

  @override
  VideoScreenReelsState createState() => VideoScreenReelsState();
}

class VideoScreenReelsState extends State<VideoScreenReels>
    with TickerProviderStateMixin {
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

  final TextEditingController _commentController = TextEditingController();
  final List<String> comments = []; // Stores comments

  @override
  void initState() {
    super.initState();
    initializeVideoPlayer();
    _setupAnimationControllers();
    _fetchComments();
    _fetchLikedVideos();
  }

  Future<void> _fetchLikedVideos() async {
    var url =
        'http://15.207.244.117:8080/api/liked_videos/${TeamPageState.username}/';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List<dynamic> likedVideos = jsonDecode(response.body);
        bool liked = likedVideos.any((video) => video['id'] == widget.vidId);
        setState(() {
          isLiked = liked;
        });
      } else {
        print("Failed to fetch liked videos: ${response.body}");
      }
    } catch (e) {
      print("Error fetching liked videos: $e");
    }
  }

  void _setupAnimationControllers() {
    _overlayAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _overlayAnimationController,
      curve: Curves.easeInOut,
    );
    _commentSheetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  Future<void> _submitLike() async {
    try {
      int vidId = widget.vidId;
      var apiUrl = "${global.url}api/$vidId/update-like/";

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": TeamPageState.username}),
      );

      if (response.statusCode == 200) {
        print(response.body);
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      print("Error submitting like: $e");
    }
  }

  Future<void> _postComment(String comment) async {
    const url = 'http://15.207.244.117:8080/api/post_comment/';
    final body = jsonEncode({
      "video_id": widget.vidId,
      "content": comment,
      "posted_by": TeamPageState.username,
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Comment posted successfully: ${response.body}");
      } else {
        print("Failed to post comment: ${response.body}");
      }
    } catch (e) {
      print("Error posting comment: $e");
    }
  }

  Future<void> _fetchComments() async {
    var url =
        'http://15.207.244.117:8080/api/fetch_comments/?video_id=${widget.vidId}';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        List<String> fetchedComments = [];
        if (jsonData != null && jsonData["data"] != null) {
          for (var comment in jsonData["data"]) {
            String displayComment =
                "${comment['posted_by']}: ${comment['content']}";
            fetchedComments.add(displayComment);
          }
        }
        setState(() {
          comments
            ..clear()
            ..addAll(fetchedComments);
        });
      } else {
        print("Failed to fetch comments: ${response.body}");
      }
    } catch (e) {
      print("Error fetching comments: $e");
    }
  }

  void _handleLike() {
    if (!isLiked) {
      setState(() {
        if (isDisliked) isDisliked = false;
        isLiked = true;
      });
      _submitLike();
      _showLikeAnimation();
      _showSnackBar("Thank you for Liking this video", Colors.blue);
    } else {
      _showLikeAnimation();
      _showSnackBar("You have already Liked this video", Colors.blue);
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showLikeAnimation() {
    final double snackBarHeight = 500.0;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double topMargin = (screenHeight - snackBarHeight) / 2;

    final snackBar = SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      duration: const Duration(seconds: 1),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(top: topMargin, left: 20, right: 20),
      content: SizedBox(
        height: snackBarHeight,
        child: Lottie.asset(
          'assets/animated/likeHeart.json',
          repeat: false,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              CupertinoIcons.heart_fill,
              color: Colors.red,
              size: 150,
            );
          },
        ),
      ),
    );

    // Remove any current SnackBar and show the new one.
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }


  void _showCommentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CommentSheet(
        comments: comments,
        onCommentSubmitted: (comment) async {
          await _postComment(comment);
          await _fetchComments();
          if (context.mounted) {
            _showSnackBar("Your comment will be shown post approval", Colors.blue);
          }
        },
      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vidName),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Stack(
        children: [
          // Video Player with Tap Gesture
          GestureDetector(
            onDoubleTap: _handleLike, // Double-tap to like
            onTap: () {
              togglePlayPause();
              setState(() {
                showPlayPauseOverlay = true;
              });
              _overlayAnimationController.forward(from: 0.0);
              Future.delayed(const Duration(seconds: 2), () {
                _overlayAnimationController.reverse();
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: AspectRatio(
                    aspectRatio: _videoPlayerController.value.aspectRatio,
                    child: CustomVideoPlayer(
                      customVideoPlayerController: _customVideoPlayerController,
                    ),
                  ),
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
          // Social Interaction Buttons
          Positioned(
            right: 30,
            bottom: MediaQuery.of(context).size.height * 0.1,
            child: Column(
              children: [
                _SocialButton(
                  icon: isLiked
                      ? CupertinoIcons.heart_fill
                      : CupertinoIcons.heart,
                  onTap: _handleLike,
                  isActive: isLiked,
                ),
                const SizedBox(height: 16),
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
    String videoUrl = widget.vidUrl;

    _videoPlayerController =
    VideoPlayerController.networkUrl(Uri.parse(videoUrl))
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
        _showSnackBar('Error loading video: $error', Colors.red);
      });

    _customVideoPlayerController = CustomVideoPlayerController(
      context: context,
      videoPlayerController: _videoPlayerController,
      customVideoPlayerSettings: const CustomVideoPlayerSettings(
        playbackSpeedButtonAvailable: true,
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

// Social button widget for like and comment buttons
class _SocialButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;
  final String? badge;

  const _SocialButton({
    Key? key,
    required this.icon,
    required this.onTap,
    this.isActive = false,
    this.badge,
  }) : super(key: key);

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
              color: isActive ? Colors.red : Colors.white,
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
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                badge!,
                style: const TextStyle(
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

// Comment sheet widget
class _CommentSheet extends StatefulWidget {
  final List<String> comments;
  final Future<void> Function(String) onCommentSubmitted;

  const _CommentSheet({
    Key? key,
    required this.comments,
    required this.onCommentSubmitted,
  }) : super(key: key);

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
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
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
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Comment section title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.comment, size: 20),
                const SizedBox(width: 8),
                Text(
                  "Comments (${widget.comments.length})",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // Comments list
          Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
              minHeight: 100,
            ),
            child: widget.comments.isEmpty
                ? const Center(
              child: Text(
                "No comments yet. Be the first to comment!",
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: widget.comments.length,
              separatorBuilder: (context, index) =>
              const Divider(height: 1),
              itemBuilder: (context, index) {
                final parts = widget.comments[index].split(': ');
                final username = parts[0];
                final commentText =
                parts.sublist(1).join(': '); // handles extra colons

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey[300],
                        radius: 16,
                        child: Text(
                          username.isNotEmpty
                              ? username[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              username,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              commentText,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Comment input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              border: Border(
                top: BorderSide(
                  color: Colors.grey[300]!,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: theme.primaryColor),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      filled: true,
                      fillColor: theme.scaffoldBackgroundColor,
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () async {
                      if (_commentController.text.isNotEmpty) {
                        await widget.onCommentSubmitted(_commentController.text);
                        _commentController.clear();
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

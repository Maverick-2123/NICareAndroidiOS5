import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nicare/pages/video_player_reels.dart';
import 'dart:convert';
import 'video_player.dart'; // Import your VideoScreen class
import 'global.dart' as global;

class ReelsPage extends StatefulWidget {
  @override
  _ReelsPageState createState() => _ReelsPageState();
}

class _ReelsPageState extends State<ReelsPage> {
  late PageController _pageController;
  List<Map<String, dynamic>> videoData = [];
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fetchVideos(); // Fetch videos from the API
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchVideos() async {
    final response = await http.get(Uri.parse(global.url+'api/videoapi'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        videoData = data.map((item) => {
          'title': item['title'],
          'url': item['url'],
          'category': item['category'],
        }).toList();
      });
    } else {
      print('Failed to fetch videos: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: videoData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : PageView.builder(
        scrollDirection: Axis.vertical,
        controller: _pageController,
        itemCount: videoData.length,
        onPageChanged: (index) {
          setState(() {
            currentPage = index;
          });
        },
        itemBuilder: (context, index) {
          return VideoScreenReels(videoData[index]['title'],videoData[index]['url']); // Use your custom player here
        },
      ),
    );
  }
}

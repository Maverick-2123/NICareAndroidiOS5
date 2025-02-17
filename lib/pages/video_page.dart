import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nicare/pages/MyDrawer.dart';
import 'package:nicare/pages/language_constants.dart';
import 'package:nicare/pages/video_card.dart';
import 'package:nicare/pages/video_screen_search.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:http/http.dart' as http;
import '../models/video_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'global.dart' as global;

void main() {
  runApp(const VideoPage());
}

class VideoPage extends StatefulWidget {

  final int selectedTabIndex;

  const VideoPage({super.key,this.selectedTabIndex = 0});


  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> with SingleTickerProviderStateMixin {
  List<VideoModel> videos = []; // Stores the fetched video data
  List<String> searchTerms = []; // Stores video titles for searching
  List<String> searchLinks = []; // Stores video URLs for searching
  List<String> thumbnails = [];

  bool isLoading = true;
  String baseURL = global.url+'api/videoapi';
  // String baseURL = 'http://172.20.10.7:8080/api/videoapi';
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this, initialIndex: widget.selectedTabIndex);
    fetchVideos(); // Fetch videos when the widget is first built
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  // Fetch the video data from the server
  Future<void> fetchVideos() async {
    try {
      final response = await http.get(
          Uri.parse(baseURL));
      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);
        List<VideoModel> fetchedVideos =
        jsonData.map((json) => VideoModel.fromJson(json)).toList();

        setState(() {
          videos = fetchedVideos;
          searchTerms = videos.map((video) => video.title ?? '').toList();
          searchLinks = videos.map((video) => video.url ?? '').toList();
          thumbnails = videos.map((video) => video.thumbnail ?? '').toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load video data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
    }
  }

  // Filter videos based on the selected category index
  List<VideoModel> _getFilteredVideos(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return videos.where((video) => video.category == 'Knowledge Base Videos').toList();
      case 1:
        return videos.where((video) => video.category == 'Hardware Information Videos').toList();
      case 2:
        return videos.where((video) => video.category == 'Hardware Replacement Videos').toList();
      case 3:
        return videos.where((video) => video.category == 'Preventive Maintenance').toList();
      case 4:
        return videos.where((video) => video.category == 'Troubleshooting Guidance').toList();
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        // drawer: Mydrawer(),
        backgroundColor: Color(0xffF0F8FF),
        appBar: AppBar(
          leading: IconButton(onPressed: (){
            Navigator.of(context).pop();
          }, icon: Icon(CupertinoIcons.back)),
          backgroundColor: Color(0xffF0F8FF),
          centerTitle: true,
          title: Text(
            translation(context).homepagevideos,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.blue,
            labelColor: Colors.black,
            isScrollable: true,
            tabs: [
              Tab(text: translation(context)!.knowledge),
              Tab(text: translation(context)!.hardware),
              Tab(text: translation(context)!.hardware_repl),
              Tab(text: translation(context)!.preventive),
              Tab(text: translation(context)!.trobleshooting),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: CustomSearchDelegate(searchTerms: searchTerms, searchLinks: searchLinks),
                );
              },
              icon: Icon(CupertinoIcons.search, color: Colors.black),
            ),
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
          controller: _tabController,
          children: [
            buildVideoGrid(0), // Field Procedure Guide Tab
            buildVideoGrid(1), // Knowledge Videos Tab
            buildVideoGrid(2), // Hardware Information Tab
            buildVideoGrid(3),
            buildVideoGrid(4),
          ],
        ),
      ),
    );
  }

  Widget buildVideoGrid(int tabIndex) {
    List<VideoModel> filteredVideos = _getFilteredVideos(tabIndex);

    return filteredVideos.isEmpty
        ? const Center(child: Text('No videos available'))
        : GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: filteredVideos.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemBuilder: (context, index) => ModernVideoCard(
        index: index,
        titles: filteredVideos.map((video) => video.title ?? '').toList(),
        searchLinks: filteredVideos.map((video) => video.url ?? '').toList(),
        thumbnails: filteredVideos.map((video) => video.thumbnail ?? '').toList(),
      ), // Pass the filtered videos to VideoCard
    );
  }
}

class CustomSearchDelegate extends SearchDelegate {
  final List<String> searchTerms;
  final List<String> searchLinks;
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool isListening = false;

  CustomSearchDelegate({required this.searchTerms, required this.searchLinks}) {
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    if (_speechEnabled) {
      print('Speech recognition initialized.');
    } else {
      print('Speech recognition is not available.');
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    query = result.recognizedWords;
  }

  void _startListening() async {
    if (_speechEnabled && !isListening) {
      await _speechToText.listen(
        onResult: _onSpeechResult,
      );
      isListening = true;
      print('Listening started...');
    }
  }

  void _stopListening() async {
    if (isListening) {
      await _speechToText.stop();
      isListening = false;
      print('Listening stopped...');
    }
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: isListening ? _stopListening : _startListening,
        icon: Icon(isListening ? Icons.mic : CupertinoIcons.mic_fill),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<String> matchQuery = [];
    for (var term in searchTerms) {
      if (term.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(term);
      }
    }

    return matchQuery.isEmpty
        ? const Center(child: Text('No results found'))
        : ListView.builder(
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(result),
        );
      },
      itemCount: matchQuery.length,
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> matchQuery = [];
    for (var term in searchTerms) {
      if (term.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(term);
      }
    }

    return ListView.builder(
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          onTap: () {
            PersistentNavBarNavigator.pushNewScreen(
              context,
              screen: VideoScreenSearch(searchLinks[searchTerms.indexOf(result)]),
              withNavBar: false,
              pageTransitionAnimation: PageTransitionAnimation.cupertino,
            );
          },
          title: Text(result),
        );
      },
      itemCount: matchQuery.length,
    );
  }
}
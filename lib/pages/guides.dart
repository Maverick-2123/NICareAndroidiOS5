import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nicare/models/alarm_model.dart';
import 'package:nicare/pages/MyDrawer.dart';
import 'package:nicare/pages/poa_page.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'global.dart' as global;

class GuidesPage extends StatefulWidget {
  const GuidesPage({super.key});

  @override
  State<GuidesPage> createState() => _GuidesPageState();
}

class _GuidesPageState extends State<GuidesPage> {
  List _allResults = [];
  List _resultList = [];
  final TextEditingController _searchController = TextEditingController();

  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _searchText = "";

  Timer? _searchDebounce;
  late Future<List<AlarmModel>> futureAlarms;

  // String baseURL = 'http://172.20.10.7:8080/api/alarmapi'; // Replace with your API URL.
  String baseURL = global.url+'api/alarmapi'; // Replace with your API URL.

  @override
  void initState() {
    _searchController.addListener(_onSearchChanged);
    futureAlarms = fetchAlarms();
    _speech = stt.SpeechToText(); // Initialize speech recognition
    super.initState();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      searchResultList();
    });
  }

  void searchResultList() {
    List<AlarmModel>? showResults = [];
    if (_searchController.text.isNotEmpty) {
      showResults = _allResults
          .where((alarm) =>
      alarm.alarmName.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          alarm.description.toLowerCase().contains(_searchController.text.toLowerCase()))
          .cast<AlarmModel>()
          .toList();
    } else {
      showResults = List.from(_allResults);
    }
    setState(() {
      _resultList = showResults!;
    });
  }

  Future<List<AlarmModel>> fetchAlarms() async {
    try {
      final response = await http.get(Uri.parse(baseURL));

      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);
        List<AlarmModel> alarms = jsonData.map((json) => AlarmModel.fromJson(json)).toList();
        setState(() {
          _allResults = alarms;
        });
        searchResultList();
        return alarms;
      } else {
        throw Exception('Failed to load alarms. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }

  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (val) => print('onStatus: $val'),
      onError: (val) => print('onError: $val'),
    );
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(onResult: (val) => setState(() {
        _searchController.text = val.recognizedWords;
      }));
    }
  }

  void _stopListening() {
    setState(() => _isListening = false);
    _speech.stop();
  }

  String removeAllHtmlTags(String htmlText) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlText.replaceAll(exp, '');
  }

  Future<void> _refreshAlarms() async {
    setState(() {
      futureAlarms = fetchAlarms();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffF0F8FF),
        centerTitle: true,
        title: Row(
          children: [
            Expanded(
              child: CupertinoSearchTextField(
                controller: _searchController,
              ),
            ),
            GestureDetector(
              onTap: _isListening ? _stopListening : _startListening,
              child: Icon(
                _isListening ? Icons.mic : Icons.mic_none,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
      drawer: Mydrawer(),
      body: FutureBuilder<List<AlarmModel>>(
        future: futureAlarms,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.black),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: Unable to connect to server.', style: GoogleFonts.poppins()),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _refreshAlarms,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('No alarms found', style: GoogleFonts.poppins()),
            );
          } else {
            return RefreshIndicator(
              onRefresh: _refreshAlarms,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: _resultList.length,
                itemBuilder: (context, index) {
                  final alarm = _resultList[index];
                  return ListTile(
                    onTap: () {
                      PersistentNavBarNavigator.pushNewScreen(
                        context,
                        screen: PoaPage(
                          alarm.alarmName.toString(),
                          alarm.alarmSortDesc.toString(),
                          alarm.description.toString(),
                          alarm.alarmPoa.toString(),
                        ),
                        withNavBar: true,
                        pageTransitionAnimation: PageTransitionAnimation.cupertino,
                      );
                    },
                    title: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alarm.alarmName.toString(),
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                            ),
                          ),
                          Text(
                            alarm.alarmSortDesc.toString(),
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    subtitle: Text(
                      removeAllHtmlTags(alarm.description.toString()),
                      style: GoogleFonts.poppins(),
                      maxLines: 3,
                    ),
                    trailing: const Icon(Icons.arrow_circle_right_outlined),
                  );
                },
                separatorBuilder: (context, index) {
                  return const Divider(height: 50, thickness: 1);
                },
              ),
            );
          }
        },
      ),
    );
  }
}

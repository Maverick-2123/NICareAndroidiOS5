// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'dart:math';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nicare/pages/MyDrawer.dart';
import 'package:nicare/pages/bot_nav_guide.dart';
import 'package:nicare/pages/bot_nav_knowledge.dart';
import 'package:nicare/pages/bot_nav_video.dart';
import 'package:nicare/pages/guides.dart';
import 'package:nicare/pages/leader_bulletin.dart';
import 'package:nicare/pages/modulepage.dart';
import 'package:nicare/pages/poa_page.dart';
import 'package:nicare/pages/team_page.dart';
import 'package:nicare/pages/testimonial_carousel.dart';
import 'package:nicare/pages/video_page.dart';
import 'package:nicare/pages/video_screen_search.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import '../fontStyle.dart';
import '../models/alarm_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/rendering.dart';
import 'global.dart' as global;
import 'quizpage.dart'; // Assuming you have a separate page for quiz modules
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'language_constants.dart';

void main() {
  runApp(const HomePage());
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late Future<List<AlarmModel>> futureAlarms;
  Map<int, Map<String, dynamic>> userScores = {};
  int myIndex = 0;
  bool isLoading = true;
  static String? profileImageUrl;
  static List sendTerms = [];
  static List latestVersion = [];

  bool hasError = false;

  final List<Map<String, String>> quizModules = List.generate(
    20,
        (index) => {
      'title': 'Module ${index + 1}',
      'description': 'Test your knowledge .',
    },
  );

  Future<void> _fetchUserScores() async {
    try {
      var scoreUrl = global.url + "api/fetch-scores/?username="+TeamPageState.username;
      final response = await http.get(Uri.parse(scoreUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> scoreList = data["data"];

        setState(() {
          userScores = {
            for (var item in scoreList)
              item["module_number"]: {
                "score": item["score"],
                "is_completed": item["is_completed"]
              }
          };
        });
      } else {
        throw Exception("Failed to load user scores");
      }
    } catch (e) {
      print("Error fetching scores: $e");
    }
  }

  Future<void> fetchLeadershipData() async {
    String apiUrl = global.url+'api/leadership-bulletin/';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          sendTerms = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
      });
    }
  }

  Future<void> _fetchProfileImage() async {
    try {
      final _profile_url = global.url+"api/fetch-img/" +"?"+"name="+TeamPageState.username;
      final response = await http.get(Uri.parse(_profile_url));
      if (response.statusCode == 200) {
        setState(() {
          final data = json.decode(response.body);
          final imagePath = data['data']['image_url']; // Get the image path
          // final baseUrl = global.url; // Use your global base URL
          // final fullImageUrl = '$baseUrl$imagePath'; // Construct the full URL
          print(imagePath);
          profileImageUrl = imagePath;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to fetch profile image")));
      }
    } catch (e) {
      print("Error fetching profile image: $e");
    }
  }

  Future<void> fetchAppVersion() async {
    String apiUrl = global.url+'api/fetch-version/';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          latestVersion = json.decode(response.body);
        });
      } else {
        setState(() {
          hasError = true;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
      });
    }
    if(global.version != latestVersion[0]['version_number']){
      final upToDateSnackbar = SnackBar(
        duration: Duration(seconds: 5),
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: AwesomeSnackbarContent(
          title: 'App Update Available No. '+latestVersion[0]['version_number'],
          message: "Kindly update the app to use",
          contentType: ContentType.failure,
        ),
        behavior: SnackBarBehavior.floating,
      );
      ScaffoldMessenger.of(context).showSnackBar(upToDateSnackbar);
      Mydrawer().logout(context);
    }

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }
  // List<Widget> myItems = ;
  int currentIndex = 0;

  // String baseURL = 'http://172.20.10.7:8080/alarmapi';
  String baseURL = global.url+'api/alarmapi';
  @override
  void initState() {
    super.initState();
    fetchLeadershipData();
    _fetchProfileImage();
    _fetchUserScores();
    fetchAppVersion();
    futureAlarms = fetchAlarms();
  }

  Future<List<AlarmModel>> fetchAlarms() async {
    try {
      final response = await http.get(Uri.parse(baseURL));

      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((json) => AlarmModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load alarms. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    double screenWidth = MediaQuery
        .of(context)
        .size
        .width;

      return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xffF0F8FF),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Image.asset(
                'assets/logo_big.png',
                // 'assets/testlogo.jpeg',
                height: 30,
              ),
            ),
          ],
        ),

        backgroundColor: Color(0xffF0F8FF),
        drawer: Mydrawer(),
        body: isLoading
            ? const Center(
          child: CircularProgressIndicator(),  // Show CircularProgressIndicator while loading
        )
            : SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.only(bottom: screenHeight * 0.1),
            child: Center(
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Text(
                      translation(context).bulletin,
                      style: AppTextStyles.bold(
                        fontSize: 16,
                        color: Colors.black
                      ),
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.01,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: CarouselSlider(
                      options: CarouselOptions(
                        autoPlayCurve: Curves.fastOutSlowIn,
                        autoPlayAnimationDuration: const Duration(milliseconds: 800),
                        autoPlayInterval: const Duration(seconds: 6),
                        aspectRatio: 0.5,
                        enlargeCenterPage: true,
                        clipBehavior: Clip.none,
                        onPageChanged: (index, reason){
                          setState(() {
                            currentIndex = index;
                          });
                        },
                        height: screenHeight*0.23,
                        autoPlay: true
                      ),
                      items: sendTerms.map((term) {
                        return LeaderBulletin(
                          term['name'],
                          term['designation'],
                          term['message'],
                          term['viva_url']
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.01,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text(translation(context).homepagevideos,
                          style: AppTextStyles.bold(
                            fontSize: 16,
                            color: Colors.black
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        height: screenHeight * 0.23,
                        width: screenWidth,
                        child: ListView(
                            padding: EdgeInsets.only(left: 20, right: 20),
                            scrollDirection: Axis.horizontal,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: InkWell(
                                  onTap: (){
                                    PersistentNavBarNavigator.pushNewScreen(
                                      context,
                                      screen: VideoPage(selectedTabIndex: 0,),
                                      withNavBar: false, // OPTIONAL VALUE. True by default.
                                      pageTransitionAnimation: PageTransitionAnimation.cupertino,
                                    );
                                  },
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                          child: Image.asset('assets/poster3.jpeg', height: screenHeight*0.15)),
                                      SizedBox(height: screenHeight*0.015,),
                                      Text(translation(context).knowledge, style: AppTextStyles.bold(
                                        fontSize: 14,
                                        color: Colors.black
                                      ),),

                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: InkWell(
                                  onTap: (){
                                    PersistentNavBarNavigator.pushNewScreen(
                                      context,
                                      screen: VideoPage(selectedTabIndex: 1,),
                                      withNavBar: false, // OPTIONAL VALUE. True by default.
                                      pageTransitionAnimation: PageTransitionAnimation.cupertino,
                                    );
                                  },
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Image.asset('assets/poster4.jpeg', height: screenHeight*0.15)),
                                      SizedBox(height: screenHeight*0.015,),
                                      Text(translation(context).hardware, style: AppTextStyles.bold(
                                          fontSize: 14,
                                          color: Colors.black
                                      ),),

                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: InkWell(
                                  onTap: (){
                                    PersistentNavBarNavigator.pushNewScreen(
                                      context,
                                      screen: VideoPage(selectedTabIndex: 2,),
                                      withNavBar: false, // OPTIONAL VALUE. True by default.
                                      pageTransitionAnimation: PageTransitionAnimation.cupertino,
                                    );
                                  },
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Image.asset('assets/poster5.jpeg', height: screenHeight*0.15)),
                                      SizedBox(height: screenHeight*0.015,),
                                      Text(translation(context).hardware_repl, style: AppTextStyles.bold(
                                          fontSize: 14,
                                          color: Colors.black
                                      ),),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: InkWell(
                                  onTap: (){
                                    PersistentNavBarNavigator.pushNewScreen(
                                      context,
                                      screen: VideoPage(selectedTabIndex: 3,),
                                      withNavBar: false, // OPTIONAL VALUE. True by default.
                                      pageTransitionAnimation: PageTransitionAnimation.cupertino,
                                    );
                                  },
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Image.asset('assets/poster6.jpeg', height: screenHeight*0.15)),
                                      SizedBox(height: screenHeight*0.015,),
                                      Text(translation(context).preventive, style: AppTextStyles.bold(
                                          fontSize: 14,
                                          color: Colors.black
                                      ),),

                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: InkWell(
                                  onTap: (){
                                    PersistentNavBarNavigator.pushNewScreen(
                                      context,
                                      screen: VideoPage(selectedTabIndex: 4,),
                                      withNavBar: false, // OPTIONAL VALUE. True by default.
                                      pageTransitionAnimation: PageTransitionAnimation.cupertino,
                                    );
                                  },
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Image.asset('assets/poster7.jpeg', height: screenHeight*0.15)),
                                      SizedBox(height: screenHeight*0.015,),
                                      Text(translation(context).trobleshooting, style: AppTextStyles.bold(
                                          fontSize: 14,
                                          color: Colors.black
                                      ),),

                                    ],
                                  ),
                                ),
                              ),
                            ]),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, top: 4),
                        child: Text(
                          translation(context).homepagealarms,
                          style: AppTextStyles.bold(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            PersistentNavBarNavigator.pushNewScreen(
                              context,
                              screen: BotNavGuide(),
                              withNavBar: false, // OPTIONAL VALUE. True by default.
                              pageTransitionAnimation: PageTransitionAnimation.cupertino,
                            );
                          },
                          icon: Icon(Icons.arrow_circle_right_outlined)),
                    ],
                  ),

                  FutureBuilder<List<AlarmModel>>(
                    future: futureAlarms,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator(color: Colors.black));
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Error loading alarms.',
                                style: AppTextStyles.regular(
                                  color: Colors.black,
                                  fontSize: 10,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    futureAlarms = fetchAlarms();
                                  });
                                },
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Text(
                            'No alarms found',
                            style: AppTextStyles.regular(
                              color: Colors.black,
                              fontSize: 10,
                            ),
                          ),
                        );
                      } else {
                        final alarms = snapshot.data!;
                        return SizedBox(
                          height: screenHeight * 0.14,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: 5,
                            itemBuilder: (context, index) {
                              final alarm = alarms[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12.0),
                                child: GestureDetector(
                                  onTap: () {
                                    PersistentNavBarNavigator.pushNewScreen(
                                      context,
                                      screen: PoaPage(
                                        alarm.alarmName.toString(),
                                        alarm.alarmSortDesc.toString(),
                                        alarm.description.toString(),
                                        alarm.alarmPoa.toString(),
                                      ),
                                      withNavBar: false,
                                      pageTransitionAnimation: PageTransitionAnimation.cupertino,
                                    );
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(horizontal: 8.0),
                                    width: screenWidth * 0.45,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.red),
                                      color: Color(0xffF9F9F9),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black87.withOpacity(0.1),
                                          spreadRadius: 1,
                                          blurRadius: 13,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            alarm.alarmName ?? "No Name",
                                            style: AppTextStyles.bold(
                                              fontSize: 14,
                                              color: Colors.black
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            maxLines: 1,
                                            alarm.alarmSortDesc ?? "No Description",
                                            style: AppTextStyles.regular(
                                              fontSize: 10,
                                              color: Colors.black
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          // Text(
                                          //   maxLines: 2,
                                          //   "Description: ${alarm.description ?? "Not available"}",
                                          //   style: AppTextStyles.regular(
                                          //     fontSize: 12,
                                          //   ),
                                          // ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }
                    },
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, top: 8),
                        child: Text(
                          translation(context).homepagequiz,
                          style: AppTextStyles.bold(
                            fontSize: 16,
                           color: Colors.black
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  SizedBox(
                    height: screenHeight * 0.1,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: quizModules.length,
                      itemBuilder: (context, index) {
                        final module = quizModules[index];
                        bool isCompleted = userScores[index + 1]?["is_completed"] ?? false;
                        return GestureDetector(
                          onTap: () {
                            PersistentNavBarNavigator.pushNewScreen(
                              context,
                              screen: ModulePage(),
                              withNavBar: false, // OPTIONAL VALUE. True by default.
                              pageTransitionAnimation: PageTransitionAnimation.cupertino,
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 10.0),
                            width: screenWidth * 0.5,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isCompleted ? Colors.green : Color(0xff9C27B0), // Green if completed
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        module['title']!,
                                        style: AppTextStyles.bold(
                                          fontSize: 14,
                                          color: Colors.black
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Icon(
                                        isCompleted ? Icons.check_circle : Icons.hourglass_empty, // ✅ or ⏳
                                        color: isCompleted ? Colors.green : Colors.orange, // Green for completed, orange for pending
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    isCompleted
                                        ? translation(context).complete // Show "Completed" if done
                                        : translation(context).incomplete, // Show "Incomplete" otherwise
                                    style: AppTextStyles.regular(
                                      fontSize: 12,
                                      color: isCompleted ? Colors.green : Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  // TestimonialCarousel(),
                ],
              ),
            ),
          ),
        ),
      );
    }
}
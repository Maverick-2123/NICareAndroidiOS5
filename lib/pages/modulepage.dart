import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nicare/pages/language_constants.dart';
import 'package:nicare/pages/team_page.dart';
import 'quizpage.dart';
import 'global.dart' as global;

class ModulePage extends StatefulWidget {
  @override
  _ModulePageState createState() => _ModulePageState();
}

class _ModulePageState extends State<ModulePage> {
  List<List<Map<String, dynamic>>> modules = [];
  Map<int, Map<String, dynamic>> userScores = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAndProcessQuestions();
    _fetchUserScores();
  }

  Future<void> _fetchAndProcessQuestions() async {
    try {
      var apiUrl = global.url + "api/quiz/";
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> allQuestions =
        List<Map<String, dynamic>>.from(json.decode(response.body));

        List<Map<String, dynamic>> filteredQuestions = allQuestions.sublist(0, 300);
        List<List<Map<String, dynamic>>> dividedModules = [];
        for (int i = 0; i < 20; i++) {
          dividedModules.add(filteredQuestions.sublist(i * 15, (i + 1) * 15));
        }

        setState(() {
          modules = dividedModules;
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load questions from API");
      }
    } catch (e) {
      print("Error fetching questions: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(translation(context).homepagequiz),
        titleTextStyle: TextStyle(fontSize: 16, color: Colors.black),
        backgroundColor: Color(0xffF0F8FF),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          physics: BouncingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 2,
          ),
          itemCount: modules.length,
          itemBuilder: (context, index) {
            bool isCompleted = userScores[index + 1]?["is_completed"] ?? false;
            double? score = userScores[index + 1]?["score"];

            return GestureDetector(
              onTap: () async {
                bool? quizCompleted = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizPage(questions: modules[index], moduleNo: index+1),
                  ),
                );
                if (quizCompleted == true) {
                  setState(() {
                    // Refresh the module list so the completed quiz is updated
                    _fetchUserScores();
                  });
                }
              },
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                color: isCompleted ? Colors.green[200] : Colors.blue[200],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isCompleted ? Icons.check_circle : Icons.hourglass_empty, // Hourglass for pending quizzes
                      size: 50,
                      color: isCompleted ? Colors.green : Colors.blue, // Use blue instead of red
                    ),
                    SizedBox(height: 10),
                    Text(
                      translation(context).module + ' ${index + 1}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        isCompleted
                            ? translation(context).complete
                            : translation(context).incomplete, // Show "Incomplete" instead of a red failure indication
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      )
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

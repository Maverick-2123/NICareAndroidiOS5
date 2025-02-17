import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nicare/pages/language_constants.dart';
import 'package:nicare/pages/modulepage.dart';
import 'package:nicare/pages/team_page.dart';
import 'global.dart' as global;
import 'package:http/http.dart' as http;

class QuizPage extends StatefulWidget {
  final List<Map<String, dynamic>> questions;
  final int moduleNo;

  const QuizPage({Key? key, required this.questions, required this.moduleNo}) : super(key: key);

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int currentQuestionIndex = 0;
  int score = 0;
  String? selectedOption;
  bool isAnswered = false;
  bool isCorrect = false;
  bool showCorrectAnswer = false;
  bool showFullExplanation = false;

  void _submitAnswer() {
    if (selectedOption == null || isAnswered) return;

    setState(() {
      isAnswered = true;
      isCorrect = selectedOption == widget.questions[currentQuestionIndex]['correct_answer'];
    });
  }

  void _revealAnswer() {
    setState(() {
      isAnswered = true;
      showCorrectAnswer = true;
    });
  }

  Future<void> _submitQuizResults() async {
    try {
      var apiUrl = global.url + "api/upload-scores/"; // Replace with your API endpoint
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": TeamPageState.username,
          "module_number": widget.moduleNo,
          "score": score,
          "is_completed": true,
        }),
      );
      if (response.statusCode == 201) {

      } else {
        throw Exception("Failed to submit quiz results");
      }
    } catch (e) {
      print("Error submitting results: $e");
    }
  }

  void _nextQuestion() {
    setState(() {
      if (currentQuestionIndex < widget.questions.length - 1) {
        currentQuestionIndex++;
        selectedOption = null;
        isAnswered = false;
        showCorrectAnswer = false;
        showFullExplanation = false;
      } else {
        _showCompletionDialog();
      }
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Quiz Completed"),
        content: Text("You've completed the quiz!"),
        actions: [
          ElevatedButton(
            onPressed: () {
              _submitQuizResults().then((_) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context, true); // Pass true to refresh ModulePage
              });
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  String _removeQuestionNumber(String question) {
    final regex = RegExp(r'^\d+\.\s*');
    return question.replaceAll(regex, '');
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    if (widget.questions.isEmpty) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    var questionData = widget.questions[currentQuestionIndex];
    var options = Map<String, String>.from(questionData['options'] ?? {});
    var explanation = questionData['explanation'];
    String correctAnswer = questionData['correct_answer'].toLowerCase();
    String cleanedQuestion = _removeQuestionNumber(questionData['question']);

    return Scaffold(
      backgroundColor: Color(0xFF005AFF),
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Quiz"),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "Score: $score",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              translation(context).quizquestions +
                  " ${currentQuestionIndex + 1} / ${widget.questions.length}",
              style: TextStyle(fontSize: 30, color: Colors.white),
            ),
            SizedBox(height: 10),
            Container(
              height: screenHeight * 0.75,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        cleanedQuestion,
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    SizedBox(height: 20),
                    ...options.entries.map((entry) {
                      String optionKey = entry.key.toLowerCase();
                      String optionValue = entry.value;

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black),
                          ),
                          child: Material(
                            borderRadius: BorderRadius.circular(12),
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              title: Text(optionValue),
                              onTap: isAnswered
                                  ? null
                                  : () {
                                setState(() {
                                  selectedOption = optionKey;
                                });
                                _submitAnswer();
                                if (isCorrect) {
                                  score += 1;
                                }
                                print(score);
                              },
                              tileColor: (isAnswered && optionKey == selectedOption)
                                  ? (isCorrect ? Colors.green : Colors.red)
                                  : (showCorrectAnswer && optionKey == correctAnswer
                                  ? Colors.green
                                  : Colors.transparent),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        OutlinedButton(
                          onPressed: _revealAnswer,
                          child: Text(translation(context).reveal),
                        ),
                        OutlinedButton(
                          onPressed: _nextQuestion,
                          child: Text(translation(context).skip),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: BorderSide(color: Colors.red),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: isAnswered ? _nextQuestion : null,
                          child: Text(translation(context).next),
                          style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.blue,
                              side: BorderSide(color: Colors.blue)),
                        ),
                      ],
                    ),
                    if (isAnswered) ...[
                      SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            showFullExplanation = !showFullExplanation;
                          });
                        },
                        child: Card(
                          margin: EdgeInsets.all(8),
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  translation(context).explanation,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 8),
                                if (!showFullExplanation)
                                  Text(
                                    explanation,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                if (showFullExplanation)
                                  Text(
                                    explanation,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                Text(
                                  showFullExplanation
                                      ? translation(context).showless
                                      : translation(context).showmore,
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

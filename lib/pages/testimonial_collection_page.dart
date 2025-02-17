import 'package:flutter/material.dart';
import 'package:nicare/pages/language_constants.dart';
import 'package:nicare/pages/profile_page.dart';
import 'package:nicare/pages/team_page.dart';
import 'global.dart' as global;
import 'dart:convert';
import 'home_page.dart';
import 'package:http/http.dart' as http;

class TestimonialCollectionPage extends StatefulWidget {
  @override
  _TestimonialCollectionPageState createState() =>
      _TestimonialCollectionPageState();
}

class _TestimonialCollectionPageState extends State<TestimonialCollectionPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  int _selectedStars = 0;
  bool _isSubmitted = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _nameController.text = '${TeamPageState.f_name} ${TeamPageState.l_name}';
    _designationController.text = TeamPageState.designation;
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _designationController.dispose();
    _messageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  List sendTerms = HomePageState.sendTerms;

  Future<void> _addTestimonial(String message) async {
    final url = Uri.parse(global.url + 'api/upload-testimonial/');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({
      'username': TeamPageState.username,
      'name': '${TeamPageState.f_name} ${TeamPageState.l_name}',
      'designation': TeamPageState.designation,
      'message': message,
      'rating': _selectedStars,
    });

    if(_formKey.currentState!.validate()){
      try {
        final response = await http.post(url, headers: headers, body: body);

        if (response.statusCode == 200 || response.statusCode == 201) {
          setState(() {
            sendTerms.add({
              'username': TeamPageState.username,
              'name': '${TeamPageState.f_name} ${TeamPageState.l_name}',
              'designation': TeamPageState.designation,
              'message': message,
              'rating': _selectedStars,
            });
            _isSubmitted = true; // Set the submission state
          });
          _animationController.forward();
          Future.delayed(Duration(seconds: 3), () {
            setState(() {
              _isSubmitted = false;
              _nameController.clear();
              _designationController.clear();
              _messageController.clear();
              _selectedStars = 0;
              _animationController.reset();
            });
          });

          // Wait for animation, then navigate to home screen
          await Future.delayed(Duration(seconds: 3));
          Navigator.pop(context); // Navigate back to the previous screen
        } else {
          final errorResponse = json.decode(response.body);
          throw Exception(errorResponse);
        }
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('Failed to add feedback: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    }

  }



  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          onPressed: () {
            setState(() {
              _selectedStars = index + 1;
            });
          },
          icon: Icon(
            Icons.star,
            color: index < _selectedStars ? Colors.amber : Colors.grey,
            size: 40,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(translation(context).submittestimonial),
        backgroundColor: Color(0xffF0F8FF),
      ),
      body: GestureDetector(
        onTap: (){
          FocusScope.of(context).unfocus(); // Hide the keyboard when tapping outside
        }
        ,
        child: _isSubmitted
            ? Center(
          child: ScaleTransition(
            scale: CurvedAnimation(
                parent: _animationController, curve: Curves.bounceOut),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Colors.blue, size: 100),
                const SizedBox(height: 20),
                Text(
                  'Thank You for Your Feedback!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        )
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    translation(context).feedbacktitle,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    enabled: false,
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: translation(context).name,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _designationController,
                    decoration: InputDecoration(
                      labelText: translation(context).desig,
                      enabled: false,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: Icon(Icons.badge),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your designation';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      labelText: translation(context).message,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: Icon(Icons.message),
                    ),
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your message';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    translation(context).rateus,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildStarRating(),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: (){
                      _addTestimonial(_messageController.text);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                      backgroundColor: Color(0xff0053DC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      translation(context).submit,
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

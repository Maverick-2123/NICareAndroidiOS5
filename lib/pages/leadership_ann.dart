import 'dart:convert';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:nicare/pages/home_page.dart';
import 'package:nicare/pages/language_constants.dart';
import 'package:nicare/pages/square.dart';
import 'package:nicare/pages/team_page.dart';
import 'MyDrawer.dart';
import 'global.dart' as global;

class LeadershipAnn extends StatefulWidget {
  const LeadershipAnn({super.key});

  @override
  State<LeadershipAnn> createState() => _LeadershipAnnState();
}

class _LeadershipAnnState extends State<LeadershipAnn> {
  List sendTerms = HomePageState.sendTerms;

  // Form key for validation
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState(){
    super.initState();
    _nameController.text = '${TeamPageState.f_name} ${TeamPageState.l_name}';
    _designationController.text = TeamPageState.designation;
  }

  // Function to add leadership announcement to your API
  Future<void> _addLeadershipAnnouncement(String name, String designation, String message) async {
    final url = Uri.parse(global.url+'api/add-leadership/');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({
      'name': name,
      'designation': designation,
      'message': message,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          sendTerms.add({
            'name': name,
            'designation': designation,
            'message': message,
          });
        });
      } else {
        final errorResponse = json.decode(response.body);
        throw Exception(errorResponse);
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to add announcement: $e'),
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

  // Function to show the Add Announcement dialog box
  void _showAddAnnouncementDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15), // Rounded corners
          ),
          title: Text(
           translation(context).addleadership,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      enabled: false,
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 20,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: _designationController,
                    decoration: InputDecoration(
                      enabled: false,
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 20,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a designation';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      labelText: translation(context).message,
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 20,
                      ),
                    ),
                    maxLines: 3,
                    maxLength: 100,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a message';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                translation(context).cancel,
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _addLeadershipAnnouncement(
                    _nameController.text,
                    _designationController.text,
                    _messageController.text,
                  );
                  Navigator.pop(context);
                  _nameController.clear();
                  _designationController.clear();
                  _messageController.clear();

                  final snackBar = SnackBar(
                    elevation: 0,
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.transparent,
                    content: AwesomeSnackbarContent(
                      title: 'Success',
                      message: 'The announcement will be verified and published',
                      contentType: ContentType.success,
                    ),
                  );

                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              },
              child: Text(
                translation(context).submit,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xffF0F8FF),
      appBar: AppBar(
        backgroundColor: Color(0xffF0F8FF),
        centerTitle: true,
        title: Text(
          translation(context).bulletin,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          if (TeamPageState.access == "admin") // Only show if the user is admin
            IconButton(
              onPressed: _showAddAnnouncementDialog,  // Add button triggers the dialog
              icon: Icon(Icons.add),
            )
        ],
      ),
      drawer: Mydrawer(),
      body: ListView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: sendTerms.length,
        itemBuilder: (context, index) {
          return MySquare(
            name: sendTerms[index]['name'],
            desig: sendTerms[index]['designation'],
            message: sendTerms[index]['message'],
            viva_url: sendTerms[index]['viva_url'],
          );
        },
      ),
    );
  }
}

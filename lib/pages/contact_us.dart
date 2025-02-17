import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';  // Import the package
import 'package:nicare/pages/team_page.dart';

import 'language_constants.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({super.key});

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final contactNameController = TextEditingController();
  final contactEmailController = TextEditingController();
  final subjectController = TextEditingController();
  final issueController = TextEditingController();

  @override
  void initState(){
    super.initState();
    contactNameController.text = '${TeamPageState.f_name} ${TeamPageState.l_name}';
    contactEmailController.text = TeamPageState.email;
  }

  Future<void> validateAndSave() async {
    final FormState? form = _formKey.currentState;
    if (form!.validate()) {
      final Email email = Email(
        body: issueController.text,
        subject: subjectController.text,
        recipients: ['shiv.sahu@nokia.com'],
        isHTML: false,
      );
      try {
        await FlutterEmailSender.send(email);
        contactNameController.clear();
        contactEmailController.clear();
        subjectController.clear();
        issueController.clear();

        // Show the Awesome Snackbar on success
        final snackBar = SnackBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Success!',
            message: 'Your email was sent successfully.',
            contentType: ContentType.success,
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } catch (e) {
        print(e);
        // Show the Awesome Snackbar on failure
        final snackBar = SnackBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Error!',
            message: 'Failed to send the email. Please try again.',
            contentType: ContentType.failure,
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } else {
      print('Form is invalid');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xffF0F8FF),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(CupertinoIcons.back),
        ),
        backgroundColor: Color(0xffF0F8FF),
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: (){
          FocusScope.of(context).unfocus(); // Hide the keyboard when tapping outside
        },
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.03),
              Center(
                child: Text(
                  translation(context).contact,
                  style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1),
                ),
              ),
              SizedBox(height: screenHeight * 0.05),
              Container(
                width: screenWidth * 0.9,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        translation(context).thank,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          letterSpacing: 1,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      // Name field
                      Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: contactNameController,
                            enabled: false,
                            validator: (value) => value!.isEmpty
                                ? 'Name cannot be blank'
                                : null,
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                            ),
                            decoration: InputDecoration(
                              hintText: translation(context).name,
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      // Email field
                      Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: contactEmailController,
                            enabled: false,
                            validator: (value) => value!.isEmpty
                                ? 'Email cannot be blank'
                                : null,
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                            ),
                            decoration: InputDecoration(
                              hintText: translation(context).email,
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      // Subject field
                      Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: subjectController,
                            validator: (value) => value!.isEmpty
                                ? 'Subject cannot be blank'
                                : null,
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                            ),
                            decoration: InputDecoration(
                              hintText: translation(context).subject,
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      // Issue field
                      Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: issueController,
                            validator: (value) => value!.isEmpty
                                ? 'Issue cannot be blank'
                                : null,
                            maxLines: 4,
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                            ),
                            decoration: InputDecoration(
                              hintText: translation(context).issue,
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.05),
                      // Submit button
                      Center(
                        child: ElevatedButton(
                          onPressed: validateAndSave,
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all(
                                EdgeInsets.fromLTRB(70, 15, 70, 15)),
                            backgroundColor:
                            MaterialStateProperty.all(Color(0xff0A0908)),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                          child: Text(
                            translation(context).submit,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              letterSpacing: 0.7,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      Center(
                        child: Text(
                          translation(context).or,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            letterSpacing: 1,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          translation(context).reach,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            letterSpacing: 1,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Center(
                        child: TextButton(
                          onPressed: () async {
                            await Clipboard.setData(
                                ClipboardData(text: "shiv.sahu@nokia.com"));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Email address copied to clipboard'),
                              ),
                            );
                          },
                          child: Text('shiv.sahu@nokia.com'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

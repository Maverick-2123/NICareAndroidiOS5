import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';

import 'MyDrawer.dart';
import 'language_constants.dart';

class PoaPage extends StatefulWidget {
  final String alr_name;
  final String alr_type;
  final String alr_info;
  final String alr_poa;

  PoaPage(this.alr_name, this.alr_type, this.alr_info, this.alr_poa);

  @override
  State<PoaPage> createState() => _PoaPageState();
}

class _PoaPageState extends State<PoaPage> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _showEmailDialog(String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Center(
                  child: Text(
            translation(context).sendemail,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Email Input Field
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email_outlined, color: Colors.blueAccent),
                    labelText: 'Recipient Email',
                    labelStyle: GoogleFonts.poppins(fontSize: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Cancel Button
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Text(
                      translation(context).cancel,
                        style: GoogleFonts.poppins(color: Colors.black),
                      ),
                    ),

                    // Send Button
                    TextButton(
                      onPressed: () {
                        // Here you can handle the email sending functionality.
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Text(
                      translation(context).send,
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xffF0F8FF),
        actions: [
          Image.asset(
            'assets/logo_big.png',
            height: 30,
          ),
          SizedBox(width: screenWidth * 0.05),
        ],
      ),
      backgroundColor: Color(0xffF0F8FF),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Alarm Name Row with Share Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(CupertinoIcons.exclamationmark_triangle, color: Colors.redAccent),
                      SizedBox(width: screenWidth * 0.02),
                      Text(
                        widget.alr_name,
                        style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.share, color: Colors.black),
                    onPressed: () {
                      _showEmailDialog(
                        'Alarm Name: ${widget.alr_name}\n'
                            'Alarm Type: ${widget.alr_type}\n'
                            'Alarm Description: ${widget.alr_info}\n'
                            'Plan of Action: ${widget.alr_poa}',
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),

              // Alarm Type
              Text(
                widget.alr_type,
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Divider(height: 40, thickness: 1),

              // Alarm Description Section with ExpansionTile
              ExpansionTile(
                leading: Icon(CupertinoIcons.info, color: Colors.blueAccent),
                title: Text(
                    translation(context).alm_desc,
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Html(
                      data: widget.alr_info,
                      style: {
                        "body": Style(
                          fontSize: FontSize(15.0),
                          fontFamily: 'Poppins',
                        ),
                      },
                    ),
                  ),
                ],
              ),
              Divider(height: 40, thickness: 1),

              // Plan of Action Section with ExpansionTile
              ExpansionTile(
                leading: Icon(CupertinoIcons.play_circle, color: Colors.greenAccent),
                title: Text(
                    translation(context).planof,
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Html(
                      data: widget.alr_poa,
                      style: {
                        "body": Style(
                          fontSize: FontSize(15.0),
                          fontFamily: 'Poppins',
                        ),
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
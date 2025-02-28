// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nicare/fontStyle.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nicare/pages/language_constants.dart';
import 'package:http/http.dart' as http;
import 'package:nicare/pages/register.dart';
import 'package:nicare/pages/team_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'global.dart' as global;

import '../main.dart';

void main() {
  runApp(const FirstPage());
}

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => FirstPageState();
}

class FirstPageState extends State<FirstPage> {
  static String user_name = "";
  static String phone = "";
  bool isLogin = false;

  String _country = "English";
  String _lang = "en";

  List<Map> _myJson = [
    //{'id': 0, 'image': 'assets/globe.png', 'name': 'Language ', 'lang': 'la'},
    {'id': 0, 'image': 'assets/united-states.png', 'name': 'English', 'lang': 'en'},
    {'id': 1, 'image': 'assets/spain.png', 'name': 'Español', 'lang': 'es'},
    {'id': 2, 'image': 'assets/germany.png', 'name': 'Deutsch', 'lang': 'de'},
    {'id': 3, 'image': 'assets/japan.png', 'name': '日本語', 'lang': 'ja'},
    {'id': 4, 'image': 'assets/china.png', 'name': '汉语', 'lang': 'zh'},
  ];

  final _controller_name = TextEditingController();
  final _controller_emp = TextEditingController();
  bool _validate = false;
  String error_code = "";
  String error_message = "";
  bool _isPasswordVisible = false; // Added variable

  Future<void> authError(String error_code, String? error_message) async {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: AlertDialog(
              backgroundColor: Colors.black,
              title: Center(child: Text("Alert!", style: AppTextStyles.regular(color: Colors.white, fontSize: 24, letterSpacing: 0.7))),
              content: Text(error_code + ", please try again", style: AppTextStyles.regular(color: Colors.white, fontSize: 16, letterSpacing: 0.7)),
              actions: [TextButton(onPressed: (Navigator.of(context).pop), child: Text("Continue"))],
            ),
          );
        });
  }

  Future<bool> login(String username, String password) async {
    // final url = Uri.parse('http://192.168.0.178:8080/api/login/');
    // final url = Uri.parse('http://172.20.10.6:8080/api/login/');
    if (username.contains(".com")) {
      final snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Please enter username',
          message: 'Please enter username not email',
          contentType: ContentType.failure,
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    final url = Uri.parse(global.url + "api/login/");
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', data['access']);
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userRole', data['roles']);
        await prefs.setString('field', data['tech_field']);
        await prefs.setString('f_name', data['firstname']);
        await prefs.setString('l_name', data['lastname']);
        await prefs.setString('email', data['email']);
        await prefs.setString('username', username);
        await prefs.setString('designation', data['designation']);

        print('login successful');
        Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context) => TeamPage()));
        return true;
      } else if (response.statusCode == 401) {
        final data = jsonDecode(response.body);
        final snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Approval Pending',
            message: 'Your request is under review and will be approved :)',
            contentType: ContentType.help,
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);

        return false;
      } else {
        // Show an Awesome Snackbar when login fails
        final snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Login Failed!',
            message: 'Invalid credentials or server error.',
            contentType: ContentType.failure,
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        print('login failed');
        return false;
      }
    } catch (e) {
      final snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Login Failed!',
          message: 'Server Unavailable',
          contentType: ContentType.failure,
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      print('login failed');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // backgroundColor: Colors.white,
      backgroundColor: Color(0xFFF0F8FF),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: screenHeight * 0.2,
                  ),
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: DropdownButtonHideUnderline(
                        child: ButtonTheme(
                      alignedDropdown: true,
                      child: DropdownButton<String>(
                        dropdownColor: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.black,
                        ),
                        value: _lang,
                        onChanged: (newValue) async {
                          _lang = newValue!;
                          Locale _locale = await setLocale(_lang);
                          NICare.setLocale(context, _locale);
                          setState(() {
                            _lang = newValue!;
                          });
                        },
                        items: _myJson.map((Map map) {
                          return new DropdownMenuItem<String>(
                            value: map['lang'].toString(),
                            child: Row(
                              children: [
                                Image.asset(
                                  map['image'],
                                  width: 20,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: Text(
                                    map['name'],
                                    style: AppTextStyles.regular(fontSize: 16, color: Colors.black),
                                  ),
                                )
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    )),
                  ),
                ],
              ),
            ),
            IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Text(
                  //   'NICare',
                  //   style: GoogleFonts.poppins(fontSize: 36),
                  // ),
                  Image.asset(
                    'assets/Nokia-logonew.png',
                    scale: 3,
                  ),
                  VerticalDivider(
                    width: 20,
                    thickness: 1,
                    color: Colors.black,
                  ),
                  Text(
                    global.appName,
                    style: AppTextStyles.bold(fontSize: 30, color: Colors.black),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: screenHeight * 0.12,
            ),
            Text(translation(context).details, style: AppTextStyles.bold(fontSize: 24, color: Colors.black)),
            SizedBox(
              height: screenHeight * 0.05,
            ),
            Container(
              height: screenHeight * 0.55,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                color: Color(0xFF005AFF),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Text("Name :",
                  //     style: GoogleFonts.poppins(
                  //         fontSize: 16,color: Colors.white)),
                  Container(
                    width: screenWidth * 0.75,
                    child: Form(
                      child: TextFormField(
                        controller: _controller_name,
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                        ),
                        cursorColor: Colors.blue,
                        textAlign: TextAlign.left,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          fillColor: Color(0xFFF6F6F6),
                          errorText: _validate ? "Username can't be empty" : null,
                          hintText: 'Username',
                          hintStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          filled: true,
                        ),
                      ),
                    ),
                  ),
                  // Text("Employee ID :",
                  // style: GoogleFonts.poppins(
                  //     fontSize: 16,color: Colors.white)),
                  Container(
                    width: screenWidth * 0.75,
                    child: TextField(
                      controller: _controller_emp,
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                      ),
                      cursorColor: Colors.blue,
                      textAlign: TextAlign.left,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        errorText: _validate ? "Password can't be empty" : null,
                        hintText: '*******',
                        hintStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        filled: true,
                        fillColor: Color(0xFFF6F6F6),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_controller_name.text.isEmpty || _controller_emp.text.isEmpty) {
                        setState(() {
                          _validate = true;
                        });
                      } else {
                        setState(() {
                          _validate = false;
                        });
                        login(_controller_name.text, _controller_emp.text);
                      }
                    },
                    style: ButtonStyle(
                        padding: WidgetStatePropertyAll(EdgeInsets.fromLTRB(70, 15, 70, 15)),
                        backgroundColor: WidgetStatePropertyAll(Color(0xff0A0908)),
                        // backgroundColor: WidgetStatePropertyAll(Colors.white),
                        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))))),
                    child: Text(
                      translation(context).continue_but,
                      style: AppTextStyles.regular(color: Colors.white, fontSize: 16, letterSpacing: 0.7),
                    ),
                  ),
                  // Register Button
                  TextButton(
                    onPressed: () {
                      // Navigate to RegisterPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterPage()),
                      );
                    },
                    child: Text(
                      translation(context).registerquestion,
                      style: AppTextStyles.bold(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

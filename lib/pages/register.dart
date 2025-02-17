import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:nicare/pages/confirm_page.dart';
import 'global.dart' as global;
import 'language_constants.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();

  String? _selectedTechnology;
  String? _selectedAccess;

  final List<String> _technologies = ['Optics', 'Fixed Networks', 'Internet Protocol'];
  final List<String> _accessLevels = ['Internal', 'Customer'];

  bool _validateName = false;
  bool _validateEmail = false;
  bool _validatePassword = false;
  bool _validateUsername = false;
  bool _validateDesignation = false;

  Future<void> _registerUser() async {
    final url = Uri.parse(global.url+'api/register/');
    final body = {
      "name": _nameController.text,
      "username": _usernameController.text,
      "email": _emailController.text,
      "password": _passwordController.text,
      "technology": _selectedTechnology?.toLowerCase(),
      "access": _selectedAccess,
      "designation": _designationController.text,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data["message"] == "User registered successfully") {
          // Registration successful
          Navigator.of(context).pop();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ConfirmationPage(),
            ),
          );
        } else {
          // Handle errors from API
          _handleErrors(data["error"]);
        }
      } else {
        // Handle server errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      // Handle network errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    }
  }

  void _handleErrors(Map<String, dynamic> errors) {
    setState(() {
      _validateName = errors.containsKey("name");
      _validateUsername = errors.containsKey("username");
      _validateEmail = errors.containsKey("email");
      _validatePassword = errors.containsKey("password");
      _validateDesignation = errors.containsKey("designation");
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please fix the errors and try again.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xFF1E1E2A),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    Text(
                      translation(context).register,
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0078FF),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
              Container(
                height: screenHeight * 0.8,
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {});
                  },
                  children: [
                    _buildStepPage(
                      title: translation(context).step,
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: _nameController,
                            hintText: translation(context).entername,
                            errorText: _validateName ? "Name can't be empty" : null,
                          ),
                          SizedBox(height: 15),
                          _buildTextField(
                            controller: _usernameController,
                            hintText: translation(context).enteruser,
                            errorText: _validateUsername ? "Username can't be empty" : null,
                          ),
                          SizedBox(height: 15),
                          _buildTextField(
                            controller: _designationController,
                            hintText: "Enter designation",
                            errorText: _validateDesignation ? "Designation can't be empty" : null,
                            keyboardType: TextInputType.text,
                          ),
                          SizedBox(height: 15),
                          _buildTextField(
                            controller: _emailController,
                            hintText: translation(context).enteremail,
                            errorText: _validateEmail ? "Email can't be empty" : null,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          SizedBox(height: 30),
                          _buildNextButton(() {
                            setState(() {
                              _validateName = _nameController.text.isEmpty;
                              _validateUsername = _usernameController.text.isEmpty;
                              _validateEmail = _emailController.text.isEmpty;
                            });
                            if (!_validateName && !_validateEmail && ! _validateUsername) {
                              _pageController.nextPage(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeIn,
                              );
                            }
                          }),
                          SizedBox(height: 10),
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Go back to Login page
                              },
                              child: Text(
                                translation(context).login_question,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 14,
                                  decoration: TextDecoration.underline,
                                ),
                              )
                          )
                        ],
                      ),
                    ),
                    _buildStepPage(
                      title: translation(context).steptwo,
                      child: Column(
                        children: [
                          _buildDropdown(
                            hint: translation(context).selecttech,
                            items: _technologies,
                            value: _selectedTechnology,
                            onChanged: (value) {
                              setState(() {
                                _selectedTechnology = value;
                              });
                            },
                          ),
                          SizedBox(height: 15),
                          _buildDropdown(
                            hint: translation(context).selectaccess,
                            items: _accessLevels,
                            value: _selectedAccess,
                            onChanged: (value) {
                              setState(() {
                                _selectedAccess = value;
                              });
                            },
                          ),
                          SizedBox(height: 30),
                          _buildNextButton(() {
                            if (_selectedTechnology != null && _selectedAccess != null) {
                              _pageController.nextPage(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeIn,
                              );
                            }
                          }),
                        ],
                      ),
                    ),
                    _buildStepPage(
                      title: translation(context).stepthree,
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: _passwordController,
                            hintText: translation(context).enterpassword,
                            errorText: _validatePassword ? "Password can't be empty" : null,
                            obscureText: true,
                          ),
                          SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _validatePassword = _passwordController.text.isEmpty;
                              });
                              if (!_validatePassword) {
                                // Perform registration logic
                                _registerUser();
                              }
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Color(0xFF0078FF)),
                              padding: MaterialStateProperty.all(
                                EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                              ),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            child: Text(
                              translation(context).register,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepPage({required String title, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0078FF)),
          ),
          SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    String? errorText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16),
        cursorColor: Colors.white,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          errorText: errorText,
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(fontWeight: FontWeight.w400, color: Colors.grey),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Color(0xFF2A2A3B),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required List<String> items,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A3B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        hint: Text(
          hint,
          style: GoogleFonts.poppins(color: Colors.grey, fontWeight: FontWeight.w400),
        ),
        value: items.contains(value) ? value : null, // Ensure valid selection
        isExpanded: true,
        underline: SizedBox(),
        icon: Icon(Icons.arrow_drop_down, color: Colors.white),
        items: items.map((String item) {
          final isDisabled = item == 'Fixed Networks' || item == 'Internet Protocol'; // Disable specific items
          return DropdownMenuItem<String>(
            value: isDisabled ? null : item, // Assign null if disabled
            enabled: !isDisabled, // Disable item from being selectable
            child: Text(
              item,
              style: GoogleFonts.poppins(
                color: isDisabled ? Colors.grey : Colors.blue, // Grey out disabled items
                fontWeight: isDisabled ? FontWeight.w400 : FontWeight.w500,
              ),
            ),
          );
        }).toList(),
        onChanged: (selectedItem) {
          if (selectedItem != null) {
            onChanged(selectedItem); // Only call onChanged for valid selections
          }
        },
      ),
    );
  }

  Widget _buildNextButton(VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Color(0xFF0078FF)),
        padding: MaterialStateProperty.all(
          EdgeInsets.symmetric(horizontal: 80, vertical: 15),
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      child: Text(
        translation(context).next,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

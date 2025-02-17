import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nicare/pages/team_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:path_provider/path_provider.dart';
import '../main.dart';
import 'language_constants.dart';
import 'global.dart' as global;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String f_name = TeamPageState.f_name;
  String l_name = TeamPageState.l_name;
  String field = TeamPageState.field;
  String access = TeamPageState.access;
  String email = TeamPageState.email;
  String username = TeamPageState.username;
  String designation = TeamPageState.designation;
  final String apiEndpoint = global.url+"api/fetch-img/"; // Replace with your API endpoint
  final String uploadEndpoint = global.url+"api/upload-img/";
  File? _profileImage;
  String? _profileImageUrl;

  String _lang = "la";
  final List<Map<String, String>> languages = [
    {'lang': 'la', 'image': 'assets/globe.png', 'name': 'Language'},
    {'lang': 'en', 'image': 'assets/united-states.png', 'name': 'English'},
    {'lang': 'es', 'image': 'assets/spain.png', 'name': 'Español'},
    {'lang': 'de', 'image': 'assets/germany.png', 'name': 'Deutsch'},
    {'lang': 'ja', 'image': 'assets/japan.png', 'name': '日本語'},
    {'lang': 'zh', 'image': 'assets/china.png', 'name': '汉语'}
  ];

  @override
  void initState() {
    super.initState();
    _fetchProfileImage();
  }

  Future<void> _fetchProfileImage() async {
    try {
      final response = await http.get(Uri.parse('$apiEndpoint?name=$username'));
      if (response.statusCode == 200) {
        setState(() {
          final data = json.decode(response.body);
          final imagePath = data['data']['image_url']; // Get the image path
          // final baseUrl = global.url; // Use your global base URL
          // final fullImageUrl = '$baseUrl$imagePath'; // Construct the full URL
          print(imagePath);
          _profileImageUrl = imagePath;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to fetch profile image")));
      }
    } catch (e) {
      print("Error fetching profile image: $e");
    }
  }

  Future<void> _uploadProfileImage(File image) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(uploadEndpoint));
      request.fields['name'] = username;
      request.files.add(await http.MultipartFile.fromPath('image', image.path));

      final response = await request.send();
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Profile image updated successfully")));
        _fetchProfileImage();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to upload profile image")));
      }
    } catch (e) {
      print("Error uploading profile image: $e");
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final directory = await getTemporaryDirectory(); // Import `path_provider` for this
      final newFilePath = '${directory.path}/${username}_image.jpg';
      final renamedFile = await File(pickedFile.path).copy(newFilePath);
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      _uploadProfileImage(_profileImage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFF),
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 70, // Reduced from 200
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Color(0xFF11307A),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF11307A),
                      Color(0xFF1A237E),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: 20,
                      decoration: BoxDecoration(
                        color: Color(0xFFF8FAFF),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: Offset(0, 10), // Adjusted from -60
              child: Column(
                children: [
                  _buildProfileHeader(),
                  _buildProfileContent(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 55, // Slightly reduced from 60
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : (_profileImageUrl != null
                      ? NetworkImage(_profileImageUrl!) as ImageProvider
                      : AssetImage('assets/default_profile.jpg')),
                ),
              ),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFF11307A),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            '$f_name $l_name',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Color(0xFF11307A),
            ),
          ),
          Text(
            designation,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.tech,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          _buildInfoCard([
            InfoItem(icon: CupertinoIcons.news, title: field),
            InfoItem(icon: CupertinoIcons.location, title: access),
          ]),
          SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.contact,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          _buildInfoCard([
            InfoItem(icon: CupertinoIcons.mail, title: email),
          ]),
          SizedBox(height: 24),
          Text(
            "Language",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          _buildLanguageSelector(),
          SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildInfoCard(List<InfoItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Color(0xFF11307A).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item.icon, color: Color(0xFF11307A), size: 20),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        item.title,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (index < items.length - 1)
                Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: ButtonTheme(
          alignedDropdown: true,
          child: DropdownButton<String>(
            value: _lang,
            isExpanded: true,
            icon: Icon(Icons.keyboard_arrow_down, color: Color(0xFF11307A)),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(16),
            padding: EdgeInsets.symmetric(horizontal: 16),
            onChanged: (newValue) async {
              if (newValue != null) {
                Locale _locale = await setLocale(newValue);
                NICare.setLocale(context, _locale);
                setState(() => _lang = newValue);
              }
            },
            items: languages.map((Map<String, String> map) {
              return DropdownMenuItem<String>(
                value: map['lang'],
                child: Row(
                  children: [
                    Image.asset(map['image']!, width: 24, height: 24),
                    SizedBox(width: 12),
                    Text(
                      map['name']!,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class InfoItem {
  final IconData icon;
  final String title;

  InfoItem({required this.icon, required this.title});
}

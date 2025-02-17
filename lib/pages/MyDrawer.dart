import 'dart:math';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nicare/pages/about_page.dart';
import 'package:nicare/pages/contact_us.dart';
import 'package:nicare/pages/first_page.dart';
import 'package:nicare/pages/global.dart';
import 'package:nicare/pages/home_page.dart';
import 'package:nicare/pages/modulepage.dart';
import 'package:nicare/pages/profile_page.dart';
import 'package:nicare/pages/quizpage.dart';
import 'package:nicare/pages/team_page.dart';
import 'package:nicare/pages/testimonial_collection_page.dart';
import 'package:nicare/pages/video_page.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'language_constants.dart';
import 'global.dart' as global;
import 'package:http/http.dart' as http;

class Mydrawer extends StatefulWidget {
  @override
  State<Mydrawer> createState() => MydrawerState();

  Future<void> logout(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Clear all stored preferences
    await prefs.remove('accessToken');
    await prefs.remove('isLoggedIn');
    await prefs.remove('userRole');
    await prefs.remove('field');
    await prefs.remove('f_name');
    await prefs.remove('l_name');
    await prefs.remove('email');

    // Clear the Persistent Bottom Navigation Bar and navigate to the FirstPage
    // Navigator.pushAndRemoveUntil(
    //   context,
    //   MaterialPageRoute(builder: (context) => FirstPage()),
    //       (Route<dynamic> route) => false,  // This ensures no previous routes remain
    // );
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return FirstPage();
        },
      ),
          (_) => false,
    );
  }
}

class MydrawerState extends State<Mydrawer> {
  String user_name = TeamPageState.f_name.isNotEmpty ? TeamPageState.f_name : 'User';

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Drawer(
      elevation: 16,
      width: screenWidth * 0.85,
      child: Container(
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
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            InkWell(
              onTap: () => navigateToScreen(context, ProfilePage()),
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: HomePageState.profileImageUrl != null
                          ? NetworkImage(HomePageState.profileImageUrl!) as ImageProvider
                          : AssetImage('assets/default_profile.jpg')),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${translation(context).hi}, ${user_name.toUpperCase()}',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white.withOpacity(0.7),
                          size: 16,
                        ),
                      ],
                    ),
                    Text(
                      'View Profile',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ...buildDrawerItems(context),
          ],
        ),
      ),
    );
  }

  List<Widget> buildDrawerItems(BuildContext context) {
    final List<DrawerItem> items = [
      DrawerItem(
        icon: CupertinoIcons.doc_checkmark,
        title: translation(context).testknowledge,
        onTap: () => navigateToScreen(context, ModulePage()),
      ),
      DrawerItem(
        icon: Icons.call_outlined,
        title: translation(context).contact,
        onTap: () => navigateToScreen(context, ContactUs()),
      ),
      DrawerItem(
        icon: Icons.feedback_outlined,
        title: translation(context).feedbackDrawer,
        onTap: () => navigateToScreen(context, TestimonialCollectionPage()),
      ),
      DrawerItem(
        icon: Icons.description_outlined,
        title: translation(context).feedback,
        onTap: () => navigateToScreen(context, AboutPage()),
      ),
    ];

    List<Widget> drawerWidgets = [];
    for (var item in items) {
      drawerWidgets.add(
        Container(
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white.withOpacity(0.05),
          ),
          child: ListTile(
            leading: Icon(
              item.icon,
              color: Colors.white.withOpacity(0.9),
              size: 22,
            ),
            title: Text(
              item.title,
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.9),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: item.onTap,
            dense: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      );
    }

    // Add version info
    drawerWidgets.add(
      Container(
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white.withOpacity(0.05),
        ),
        child: ListTile(
          leading: Icon(
            CupertinoIcons.settings,
            color: Colors.white.withOpacity(0.9),
            size: 22,
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    translation(context).version,
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    global.version,
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Text(
                "Check for updates",
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          onTap: () => Navigator.of(context).pop(),
          dense: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );

    // Add logout button
    drawerWidgets.add(
      Container(
        margin: EdgeInsets.fromLTRB(12, 20, 12, 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.red.withOpacity(0.1),
        ),
        child: ListTile(
          leading: Icon(
            Icons.logout,
            color: Colors.red[300],
            size: 22,
          ),
          title: Text(
            translation(context).logout,
            style: GoogleFonts.poppins(
              color: Colors.red[300],
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          onTap: () => Mydrawer().logout(context),
          dense: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );

    return drawerWidgets;
  }

  void navigateToScreen(BuildContext context, Widget screen) {
    Navigator.of(context).pop();
    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: screen,
      withNavBar: false,
      pageTransitionAnimation: PageTransitionAnimation.cupertino,
    );
  }
}

class DrawerItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}
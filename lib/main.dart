// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:nicare/pages/first_page.dart';
import 'package:nicare/pages/guides.dart';
import 'package:nicare/pages/home_page.dart';
import 'package:nicare/pages/language_constants.dart';
import 'package:nicare/pages/leadership_ann.dart';
import 'package:nicare/pages/team_page.dart';
import 'package:nicare/pages/video_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NICare());
}

class NICare extends StatefulWidget {
  const NICare({super.key});

  @override
  State<NICare> createState() => NICareState();

  static void setLocale(BuildContext context, Locale newLocale) {
    NICareState? state = context.findAncestorStateOfType<NICareState>();
    state?.setLocale(newLocale);
  }
}

class NICareState extends State<NICare> {
  Locale? _locale;

  setLocale(Locale locale) {
    print(locale);
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) => setLocale(locale));
    super.didChangeDependencies();
  }

  final SpeechToText _speechToText = SpeechToText();

  bool isLoggedIn = false;
  bool isLoading = true;


  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

      locale: _locale,
      debugShowCheckedModeBanner: false,
      // home: FirstPage(),
      home: isLoading
      ? Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child:
        CircularProgressIndicator(
          backgroundColor: Colors.black12,
          color: Colors.white60,
        ), // Show loading indicator while checking login status
      ),
    )
        : isLoggedIn
    ? TeamPage() // Navigate to home page if the user is logged in
        : FirstPage(), // Otherwise, show login page
    );
  }
  Future<void> checkLoginStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool loggedIn = prefs.getBool('isLoggedIn') ?? false;

    // Simulate a short delay (optional) to better show the loading indicator
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      isLoggedIn = loggedIn;
      isLoading = false; // Remove the loading state after checking
    });
  }
}

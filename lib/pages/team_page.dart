import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/error_codes.dart';
import 'package:local_auth/local_auth.dart';
import 'package:nicare/pages/bot_nav.dart';
import 'package:nicare/pages/home_page.dart';
import 'package:nicare/pages/invalid_team.dart';
import 'package:nicare/pages/user_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'global.dart' as global;

import '../fontStyle.dart';
import 'language_constants.dart';
import 'leadership_ann.dart';

class TeamPage extends StatefulWidget {
  const TeamPage({super.key});

  @override
  State<TeamPage> createState() => TeamPageState();
}

class TeamPageState extends State<TeamPage> {

  static String f_name = "";
  static String l_name = "";
  static String field = "";
  static String access = "";
  static String email = "";
  static String username = "";
  static String designation = "";

  Future <void> get_details() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    f_name = prefs.getString('f_name')!;
    l_name = prefs.getString('l_name')!;
    access = prefs.getString('userRole')!;
    field = prefs.getString('field')!;
    email = prefs.getString('email')!;
    username = prefs.getString('username')!;
    designation = prefs.getString('designation')!;
  }

  @override
  void initState() {
    get_details();
    super.initState();
  }

  final LocalAuthentication _loc_auth = LocalAuthentication();

  bool _isAuthenticated = false;

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset : false,
      backgroundColor: Color(0xFFF6F6F6),
      body:
      Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(height: screenHeight*0.05,
          ),
          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Text(
                //   'NICare',
                //   style: GoogleFonts.poppins(fontSize: 36),
                // ),
                Image.asset('assets/Nokia-logonew.png',scale: 3,),
                VerticalDivider(
                  width: 20,
                  thickness: 1,
                  color: Colors.black,
                ),
                Text(
                  global.appName,
                  style: AppTextStyles.regular(fontSize: 30, color: Colors.black),
                ),
              ],
            ),
          ),

          SizedBox(height: screenHeight*0.004,),

          Text(translation(context).select_team,
              style: AppTextStyles.bold(fontSize: 18, color: Colors.black)),

          Container(
            width: screenWidth*0.9,
            height: screenHeight*0.2,
            child: ElevatedButton(
              onPressed: () async{
                if (field != "optics")
                {
                  showDialog(context: context, builder: (context)=>InvalidTeam());
                }
                else{
                  if(_isAuthenticated == false){
                    final bool canAuthenticateWithBiometrics = await _loc_auth.canCheckBiometrics;
                    if (canAuthenticateWithBiometrics){
                      try{
                        final bool didAuthenticate = await _loc_auth.authenticate(localizedReason: "Please authenticate to continue",
                            options: const AuthenticationOptions(
                                biometricOnly: false
                            ));
                        setState(() {
                          Navigator.push(
                              context, CupertinoPageRoute(builder: (_) => BotNav()));
                          _isAuthenticated = didAuthenticate;
                        });
                      }
                      catch(e){
                        print(e);
                      }
                    }
                    else{
                      Navigator.push(
                          context, CupertinoPageRoute(builder: (_) => BotNav()));
                    }

                  }
                }
              },
              style: ButtonStyle(
                // padding: WidgetStatePropertyAll(
                //     EdgeInsets.fromLTRB(70, 15, 70, 15)),
                  elevation: WidgetStateProperty.all(10),
                  backgroundColor: WidgetStatePropertyAll(Color(0xFF005AFF)),
                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15))))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset('assets/opticalFiber.png',scale: 8,),
                  Text(
                    translation(context).optics,
                    style:AppTextStyles.bold(
                        color: Colors.white, fontSize: 24, letterSpacing: 0.7),
                  ),
                  Icon(CupertinoIcons.arrow_right_circle,color: Colors.white,size: 30,),
                ],
              ),
            ),
          ),

          Container(
            width: screenWidth*0.9,
            height: screenHeight*0.2,
            child: ElevatedButton(
              onPressed: (){
                print(field);
                if (field != "IP NETWORKS")
                  {
                      showDialog(context: context, builder: (context)=>InvalidTeam());
                  }
              },
              style: ButtonStyle(
                // padding: WidgetStatePropertyAll(
                //     EdgeInsets.fromLTRB(70, 15, 70, 15)),
                  backgroundColor: WidgetStatePropertyAll(Color(0xFF005AFF)),
                  elevation: WidgetStateProperty.all(10),
                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15))))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset('assets/dns.png',scale: 8),
                  Text(
                    translation(context).ip_network,
                    style: AppTextStyles.bold(
                        color: Colors.white, fontSize: 20, letterSpacing: 0.7),
                  ),
                  Icon(CupertinoIcons.arrow_right_circle,color: Colors.white,size: 30,),
                ],
              ),
            ),
          ),
          Container(
            width: screenWidth*0.9,
            height: screenHeight*0.2,
            child: ElevatedButton(
              onPressed: (){
                if (field != "FIXED NETWORKS")
                {
                  showDialog(context: context, builder: (context)=>InvalidTeam());
                }
              },
              style: ButtonStyle(
                // padding: WidgetStatePropertyAll(
                //     EdgeInsets.fromLTRB(70, 15, 70, 15)),
                  elevation: WidgetStateProperty.all(10),
                  backgroundColor: WidgetStatePropertyAll(Color(0xFF005AFF)),
                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15))))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset('assets/fn.png',scale: 8),
                  Text(
                    translation(context).fixed_networks,
                    style: AppTextStyles.bold(
                        color: Colors.white, fontSize: 20, letterSpacing: 0.7),
                  ),
                  Icon(CupertinoIcons.arrow_right_circle,color: Colors.white,size: 30,),
                ],
              ),
            ),
          ),
          SizedBox(height: screenHeight*0.04,)
        ],
      ),
    );
  }
}

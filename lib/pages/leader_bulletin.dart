
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nicare/pages/bot_nav_lead.dart';
import 'package:nicare/pages/home_page.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import 'leadership_ann.dart';


class LeaderBulletin extends StatefulWidget {
  final String name;
  final String desig;
  final String message;
  final String viva_url;

  const LeaderBulletin(this.name,this.desig,this.message, this.viva_url);
  // const LeaderBulletin({super.key});

  @override
  State<LeaderBulletin> createState() => _LeaderBulletinState();
}

class _LeaderBulletinState extends State<LeaderBulletin> {

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return ElevatedButton(
        style: ButtonStyle(
            elevation: WidgetStateProperty.all(12),
            padding: WidgetStateProperty.all(EdgeInsets.symmetric(
                horizontal: screenWidth * 0.1,
                vertical: screenHeight * 0.04)),
            backgroundColor:
            WidgetStateProperty.all(Color(0xff0053DC)),
            shape: WidgetStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ))),
        onPressed: () {
          PersistentNavBarNavigator.pushNewScreen(
            context,
            screen: BotNavLead(),
            withNavBar: false, // OPTIONAL VALUE. True by default.
            pageTransitionAnimation: PageTransitionAnimation.cupertino,
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [

            // SizedBox(
            //   height: screenHeight * 0.015,
            // ),
            Align(
              alignment: Alignment.centerLeft,
              child: RichText(
                maxLines: 2,
                  text: TextSpan(
                      text: widget.name + ", ",
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
                      children: [
                        TextSpan(
                            text: widget.desig,
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w300))
                      ])),
            ),
            // SizedBox(
            //   height: screenHeight * 0.025,
            // ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                widget.message,
                style: GoogleFonts.poppins(
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                    fontWeight: FontWeight.w400),
              ),
            ),
          ],
        )
    );
  }
}

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'language_constants.dart';

class InvalidTeam extends StatelessWidget {
  const InvalidTeam({super.key});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: AlertDialog(
        backgroundColor: Colors.black,
        title: Center(
            child: Text(translation(context).alert,
                style: GoogleFonts.poppins(
                    color: Colors.white, fontSize: 24, letterSpacing: 0.7))),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(Icons.construction_outlined, color: Colors.white,size: 50,),
            Text(translation(context).alert_message,style: GoogleFonts.poppins(
                color: Colors.white, fontSize: 16, letterSpacing: 0.7)),
          ],
        ),
        actions: [
          TextButton(onPressed: (Navigator.of(context).pop), child: Text("Cancel"))
        ],
      ),
    );
  }
}

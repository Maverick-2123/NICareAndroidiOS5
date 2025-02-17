import 'package:flutter/material.dart';

class AppTextStyles {

  static const String _fontFamily = 'NokiaPureHeadline';

  // Bold style
  static TextStyle bold({required double fontSize, required Color color, letterSpacing}) => TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.bold,
    fontSize: fontSize,
    color: color,
    letterSpacing: letterSpacing
  );

  // Regular style
  static TextStyle regular({required double fontSize, required Color color,  letterSpacing}) => TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.normal,
    fontSize: fontSize,
    color: color,
      letterSpacing: letterSpacing
  );

  // Light style
  static TextStyle light({required double fontSize, required Color color}) => TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w300,
    fontSize: fontSize,
    color: color,
  );

  // Ultra Light style
  static TextStyle ultraLight({required double fontSize, required Color color}) => TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w200,
    fontSize: fontSize,
    color: color,
  );
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;

class AppThemes {
  static ThemeData mainTheme = ThemeData.dark().copyWith(
    textTheme: GoogleFonts.robotoMonoTextTheme(ThemeData.dark().textTheme),
    primaryTextTheme:
        GoogleFonts.robotoMonoTextTheme(ThemeData.dark().primaryTextTheme),
  );
}

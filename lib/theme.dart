import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Bright, juicy "Disney-farm" palette.
class HenColors {
  static const barnRed = Color(0xFFE2492B);
  static const sunOrange = Color(0xFFFF9E2C);
  static const corn = Color(0xFFFFC42E);
  static const cornLight = Color(0xFFFFE49A);
  static const leaf = Color(0xFF5BB24A);
  static const leafDark = Color(0xFF3C8A34);
  static const sky = Color(0xFF7FC9F2);
  static const skyDeep = Color(0xFF57B4E8);
  static const cream = Color(0xFFFFF3D6);
  static const cardCream = Color(0xFFFFFBEF);
  static const coffee = Color(0xFF5C3D1E);
  static const coffeeSoft = Color(0xFF9C7B52);
  static const white = Color(0xFFFFFFFF);
}

class HenTheme {
  static ThemeData build() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: HenColors.sunOrange,
        primary: HenColors.sunOrange,
        secondary: HenColors.leaf,
        surface: HenColors.cardCream,
      ),
      scaffoldBackgroundColor: HenColors.cream,
    );

    return base.copyWith(
      textTheme: GoogleFonts.fredokaTextTheme(base.textTheme).apply(
        bodyColor: HenColors.coffee,
        displayColor: HenColors.coffee,
      ),
      sliderTheme: base.sliderTheme.copyWith(
        activeTrackColor: HenColors.sunOrange,
        inactiveTrackColor: HenColors.cornLight,
        thumbColor: HenColors.barnRed,
        overlayColor: HenColors.sunOrange.withValues(alpha: 0.18),
        trackHeight: 8,
      ),
    );
  }
}

/// Reusable soft shadow for the chunky, juicy cards.
const List<BoxShadow> henCardShadow = [
  BoxShadow(
    color: Color(0x33935E2A),
    blurRadius: 18,
    offset: Offset(0, 8),
  ),
];

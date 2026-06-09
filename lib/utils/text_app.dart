import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class AppTextStyles {
  // Base TextStyle helper using Google Fonts (Plus Jakarta Sans)
  static TextStyle getStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize?.sp,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  // Unified pre-defined typography styles
  static TextStyle get displayLarge => getStyle(fontSize: 32, fontWeight: FontWeight.bold);
  static TextStyle get titleLarge => getStyle(fontSize: 22, fontWeight: FontWeight.bold);
  static TextStyle get titleMedium => getStyle(fontSize: 18, fontWeight: FontWeight.bold);
  static TextStyle get bodyLarge => getStyle(fontSize: 16, fontWeight: FontWeight.w500);
  static TextStyle get bodyMedium => getStyle(fontSize: 14, fontWeight: FontWeight.normal);
  static TextStyle get labelLarge => getStyle(fontSize: 16, fontWeight: FontWeight.bold);

  // Converts a base TextTheme to use the Google Fonts family globally
  static TextTheme getTextTheme(TextTheme baseTheme) {
    return GoogleFonts.plusJakartaSansTextTheme(baseTheme);
  }
}

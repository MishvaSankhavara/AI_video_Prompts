import 'package:flutter/material.dart';

class AppColors {
  // Palette A: Premium Navy & Teal Light Theme
  static const Color mainBackground = Color(0xFFFFFFFF); // Pure White
  static const Color cardBackground = Color(0xFFF0F4F8); // Very soft Slate Navy-Grey for cards

  static const Color primary = Color(0xFF121358); // Vibrant Teal (Active Accent) 0xFF121358
  static const Color secondary = Color(0xFF232F72); // Deep Navy (Bold Accents/Headers)
  static const Color border = Color(0xFFD1DBE5); // Muted Slate-Grey Border

  static const Color textPrimary = Color(0xFF121358); // Dark Navy (Primary text, replacing black) 0xFF36ADA3
  static const Color textMuted = Color(0xFF2F578A); // Slate Blue (Subtitles and secondary text)

  // Splash Screen specific colors (White background with Teal progress)
  static const Color splashBackgroundStart = Color(0xFFFFFFFF);
  static const Color splashBackgroundEnd = Color(0xFFF8FAFC);
  static const Color splashAccent = Color(0xFF121358); // Teal loader 0xFF36ADA3
}

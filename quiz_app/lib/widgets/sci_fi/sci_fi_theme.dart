import 'package:flutter/material.dart';

class SciFiTheme {
  static const Color primary = Color(0xFF00F0FF); // Neon Cyan
  static const Color secondary = Color(0xFF7000FF); // Neon Purple
  static const Color background = Color(0xFF050B14); // Deep Space Blue
  static const Color surface = Color(0xFF0A1525); // Dark Blue Surface
  static const Color success = Color(0xFF00FF9D); // Neon Green
  static const Color error = Color(0xFFFF0055); // Neon Red
  static const Color warning = Color(0xFFFFD500); // Neon Yellow
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8A9BB8);
  static const Color accent = secondary;

  static const List<BoxShadow> glow = [
    BoxShadow(
      color: Color(0x6600F0FF),
      blurRadius: 10,
      spreadRadius: 1,
    ),
  ];

  static const List<BoxShadow> glowSmall = [
    BoxShadow(
      color: Color(0x4400F0FF),
      blurRadius: 5,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> glowError = [
    BoxShadow(
      color: Color(0x66FF0055),
      blurRadius: 10,
      spreadRadius: 1,
    ),
  ];

  // Text Styles
  static TextStyle get heading1 => const TextStyle(
        fontFamily: 'Orbitron',
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textPrimary,
        letterSpacing: 2.0,
        shadows: [
          Shadow(
            color: primary,
            blurRadius: 10,
          ),
        ],
      );

  static TextStyle get heading2 => const TextStyle(
        fontFamily: 'Orbitron',
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textPrimary,
        letterSpacing: 1.5,
      );

  static TextStyle get heading3 => const TextStyle(
        fontFamily: 'Orbitron',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 1.2,
      );

  static TextStyle get body => const TextStyle(
        fontFamily: 'Roboto',
        fontSize: 16,
        color: textPrimary,
      );

  static TextStyle get caption => const TextStyle(
        fontFamily: 'Roboto',
        fontSize: 14,
        color: textSecondary,
        letterSpacing: 0.5,
      );

  static TextStyle get button => const TextStyle(
        fontFamily: 'Orbitron',
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: textPrimary,
        letterSpacing: 1.0,
      );

  // Legacy aliases for compatibility
  static TextStyle get header => heading1;
  static TextStyle get subHeader => heading2;
}

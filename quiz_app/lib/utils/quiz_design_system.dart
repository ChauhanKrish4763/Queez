import 'package:flutter/material.dart';

/// Design system constants for the live quiz feature
/// Provides consistent colors, typography, spacing, border radius, and animations

/// Color palette for quiz UI components
class QuizColors {
  // Feedback colors
  static const Color correct = Color(0xFF4CAF50); // Green
  static const Color incorrect = Color(0xFFE53935); // Red
  static const Color warning = Color(0xFFFFA726); // Orange
  static const Color info = Color(0xFF42A5F5); // Blue

  // Accent colors
  static const Color gold = Color(0xFFFFD700); // 1st place
  static const Color silver = Color(0xFFC0C0C0); // 2nd place
  static const Color bronze = Color(0xFFCD7F32); // 3rd place

  // Neutral colors
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color divider = Color(0xFFE0E0E0);
}

/// Typography styles for quiz UI components
class QuizTextStyles {
  static const TextStyle questionText = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: QuizColors.textPrimary,
  );

  static const TextStyle optionText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: QuizColors.textPrimary,
  );

  static const TextStyle scoreText = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: QuizColors.textPrimary,
  );

  static const TextStyle feedbackText = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle pointsText = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: QuizColors.gold,
  );
}

/// Spacing constants for consistent layout
class QuizSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

/// Border radius constants for consistent rounded corners
class QuizBorderRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double circular = 999.0;
}

/// Animation duration constants for consistent timing
class QuizAnimations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration feedback = Duration(milliseconds: 600);
  static const Duration counter = Duration(milliseconds: 800);
  static const Duration transition = Duration(milliseconds: 1000);
}

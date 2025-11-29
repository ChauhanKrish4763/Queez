import 'package:flutter/material.dart';
import 'package:quiz_app/CreateSection/screens/assessment_page.dart';
import 'package:quiz_app/CreateSection/screens/quiz_details.dart';
import 'package:quiz_app/CreateSection/screens/quiz_questions.dart';
import 'package:quiz_app/CreateSection/screens/learning_tools_page.dart';
import 'package:quiz_app/CreateSection/screens/study_set_details.dart';
import 'package:quiz_app/CreateSection/screens/study_set_mode_selection.dart';
import 'package:quiz_app/main.dart'; // or wherever your widgets are
import 'package:quiz_app/screens/dashboard.dart';
import 'package:quiz_app/screens/login_page.dart';
import 'package:quiz_app/ProfileSetup/profile_setup_routes.dart';

// Use typedef for clarity
typedef RouteBuilder = WidgetBuilder;

final Map<String, RouteBuilder> routeMap = {
  '/': (context) => const AppEntryPoint(),
  '/dashboard': (context) => const Dashboard(),
  '/login':
      (context) => LoginPage(
        onLoginSuccess: () {
          // Navigation is handled by LoginPage itself based on profile status
          // No need to navigate here to avoid conflicts
        },
      ),
  '/assessment_page': (context) => const AssessmentPage(),
  '/quiz_details': (context) => QuizDetails(),
  '/quiz_questions': (context) => QuizQuestions(),
  '/learning_tools_page': (context) => const LearningToolsPage(),
  '/study_set_details': (context) => const StudySetDetails(),
  '/study_set_mode_selection': (context) => const StudySetModeSelection(),
  ...profileSetupRoutes,
};

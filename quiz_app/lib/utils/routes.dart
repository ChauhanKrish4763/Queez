import 'package:flutter/material.dart';
import 'package:quiz_app/CreateSection/screens/assessment_page.dart';
import 'package:quiz_app/CreateSection/screens/quiz_details.dart';
import 'package:quiz_app/CreateSection/screens/quiz_questions.dart';
import 'package:quiz_app/LibrarySection/screens/library_item.dart';
import 'package:quiz_app/ProfileSetup/profile_setup_routes.dart';
import 'package:quiz_app/main.dart'; // or wherever your widgets are
import 'package:quiz_app/screens/dashboard.dart';
import 'package:quiz_app/screens/login_page.dart';
import 'package:quiz_app/utils/animations/page_transition.dart';

// Use typedef for clarity
typedef RouteBuilder = WidgetBuilder;

final Map<String, RouteBuilder> routeMap = {
  '/': (context) => const AppEntryPoint(),
  '/dashboard': (context) => const Dashboard(),
  '/login':
      (context) => LoginPage(
        onLoginSuccess: () {
          customNavigateReplacement(context, '/dashboard', AnimationType.fade);
        },
      ),
  '/assessment_page': (context) => const AssessmentPage(),
  '/quiz_details': (context) => QuizDetails(),
  '/quiz_questions': (context) => QuizQuestions(),
  '/library_item': (context) => const LibraryItem(),
  // Profile setup routes
  ...profileSetupRoutes,
};

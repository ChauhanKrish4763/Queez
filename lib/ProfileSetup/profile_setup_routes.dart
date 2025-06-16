import 'package:flutter/material.dart';
import 'package:quiz_app/ProfileSetup/screens/basic_info_screen.dart';
import 'package:quiz_app/ProfileSetup/screens/completion_screen.dart';
import 'package:quiz_app/ProfileSetup/screens/preferences_screen.dart';
import 'package:quiz_app/ProfileSetup/screens/role_selection_screen.dart';
import 'package:quiz_app/ProfileSetup/screens/welcome_screen.dart';

/// Map of routes for the profile setup flow
Map<String, Widget Function(BuildContext)> profileSetupRoutes = {
  '/profile_welcome': (context) => const WelcomeScreen(),
  '/profile_role': (context) => const RoleSelectionScreen(),
  '/profile_basic_info': (context) => const BasicInfoScreen(),
  '/profile_preferences': (context) => const PreferencesScreen(),
  '/profile_complete': (context) => const CompletionScreen(),
};

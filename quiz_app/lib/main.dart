import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:quiz_app/utils/animations/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Squix',
      debugShowCheckedModeBanner: false,
      home: const AppEntryPoint(),
    );
  }
}

class AppEntryPoint extends StatefulWidget {
  const AppEntryPoint({Key? key}) : super(key: key);

  @override
  State<AppEntryPoint> createState() => _AppEntryPointState();
}

class _AppEntryPointState extends State<AppEntryPoint> {
  bool _isLoading = true;
  String _lastRoute = '/login';

  @override
  void initState() {
    super.initState();
    _loadAppState();
  }

  Future<void> _loadAppState() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool('loggedIn') ?? false;
    final lastRoute = prefs.getString('lastRoute') ?? '/login';
    final profileSetupCompleted =
        prefs.getBool('profileSetupCompleted') ?? false;

    setState(() {
      // If logged in but profile setup not completed, go to profile setup
      if (loggedIn && !profileSetupCompleted) {
        _lastRoute = '/profile_welcome';
      } else {
        _lastRoute = loggedIn ? lastRoute : '/login';
      }
      _isLoading = false;
    });

    // After loading, redirect to the last route
    if (mounted) {
      final routeToNavigate = _lastRoute == '/' ? '/login' : _lastRoute;
      customNavigateReplacement(context, routeToNavigate, AnimationType.fade);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:
            _isLoading
                ? const CircularProgressIndicator()
                : const SizedBox.shrink(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quiz_app/screens/login_page.dart';
import 'package:quiz_app/screens/dashboard.dart';

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
      initialRoute: '/',
      routes: {
        '/': (context) => const _AppEntryPoint(),
        '/dashboard': (context) => const Dashboard(),
        '/login': (context) => LoginPage(
              onLoginSuccess: () {
                Navigator.pushReplacementNamed(context, '/dashboard');
              },
            ),
      },
    );
  }
}

class _AppEntryPoint extends StatefulWidget {
  const _AppEntryPoint({Key? key}) : super(key: key);

  @override
  State<_AppEntryPoint> createState() => _AppEntryPointState();
}

class _AppEntryPointState extends State<_AppEntryPoint> {
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

    setState(() {
      _lastRoute = loggedIn ? lastRoute : '/login';
      _isLoading = false;
    });

    // After loading, redirect to the last route
    if (mounted) {
      if (_lastRoute == '/') {
        // Avoid redirect loop to self
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        Navigator.pushReplacementNamed(context, _lastRoute);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while state loads
    return Scaffold(
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : const SizedBox.shrink(),
      ),
    );
  }
}

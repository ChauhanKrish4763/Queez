import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/providers/library_provider.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:quiz_app/utils/globals.dart';
import 'package:quiz_app/widgets/appbar/appbar.dart';
import 'package:quiz_app/widgets/navbar/bottom_navbar.dart';

class Dashboard extends ConsumerStatefulWidget {
  const Dashboard({super.key});

  @override
  ConsumerState<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends ConsumerState<Dashboard> {
  @override
  void initState() {
    super.initState();
    // Preload library data in the background when dashboard opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quizLibraryProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Appbar(),
      body: BottomNavbarController(key: bottomNavbarKey),
      backgroundColor: AppColors.background,
    );
  }
}

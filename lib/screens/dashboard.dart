import 'package:flutter/material.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:quiz_app/widgets/appbar/appbar.dart';
import 'package:quiz_app/widgets/navbar/bottom_navbar.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: Appbar(),
      body: BottomNavbarController(), // New main logic container
      backgroundColor: AppColors.background,
    );
  }
}

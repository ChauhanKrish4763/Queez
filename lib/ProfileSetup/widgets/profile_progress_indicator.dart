import 'package:flutter/material.dart';
import 'package:quiz_app/utils/color.dart';

class ProfileProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const ProfileProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            totalSteps,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: index + 1 == currentStep ? 24.0 : 12.0,
                height: 12.0,
                decoration: BoxDecoration(
                  color:
                      index + 1 <= currentStep
                          ? AppColors.primary
                          : AppColors.primaryLighter,
                  borderRadius: BorderRadius.circular(6.0),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

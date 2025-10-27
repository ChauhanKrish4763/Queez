import 'package:flutter/material.dart';
import 'package:quiz_app/utils/color.dart';

class ProgressTimerBar extends StatelessWidget {
  final AnimationController controller;
  final int currentIndex;
  final int total;

  const ProgressTimerBar({
    Key? key,
    required this.controller,
    required this.currentIndex,
    required this.total,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text.rich(
              TextSpan(
                text: 'Question ${currentIndex + 1}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
                children: [
                  TextSpan(
                    text: '/$total',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            return LinearProgressIndicator(
              value: controller.value,
              backgroundColor: AppColors.primaryLighter,
              color: AppColors.primary,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            );
          },
        ),
      ],
    );
  }
}

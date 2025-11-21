import 'package:flutter/material.dart';
import 'package:quiz_app/utils/color.dart';

/// Widget that displays True/False question options for live multiplayer quiz
/// Renders exactly two buttons with appropriate feedback colors and icons
class TrueFalseOptions extends StatelessWidget {
  final Function(bool) onSelect;
  final bool? selectedAnswer;
  final bool? correctAnswer;
  final bool hasAnswered;
  final bool? isCorrect;

  const TrueFalseOptions({
    super.key,
    required this.onSelect,
    this.selectedAnswer,
    this.correctAnswer,
    required this.hasAnswered,
    this.isCorrect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildOptionButton(
            context: context,
            label: 'True',
            value: true,
            icon: Icons.check_circle_outline,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildOptionButton(
            context: context,
            label: 'False',
            value: false,
            icon: Icons.cancel_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildOptionButton({
    required BuildContext context,
    required String label,
    required bool value,
    required IconData icon,
  }) {
    final isSelected = selectedAnswer == value;
    final isCorrectOption = correctAnswer == value;

    // Determine background color based on answer state
    Color backgroundColor;
    Color borderColor;
    IconData? feedbackIcon;
    Color? iconColor;

    if (hasAnswered) {
      if (isSelected) {
        // User selected this option
        if (isCorrect == true) {
          // Correct answer - green background
          backgroundColor = AppColors.success;
          borderColor = AppColors.success;
          feedbackIcon = Icons.check_circle;
          iconColor = AppColors.white;
        } else {
          // Incorrect answer - red background
          backgroundColor = AppColors.error;
          borderColor = AppColors.error;
          feedbackIcon = Icons.cancel;
          iconColor = AppColors.white;
        }
      } else if (isCorrectOption) {
        // Show correct answer with green tint (not selected)
        backgroundColor = AppColors.success.withValues(alpha: 0.3);
        borderColor = AppColors.success;
        feedbackIcon = Icons.check_circle;
        iconColor = AppColors.success;
      } else {
        // Not selected, not correct - neutral
        backgroundColor = AppColors.white;
        borderColor = Colors.grey.shade300;
      }
    } else {
      // Not answered yet - neutral state
      backgroundColor = AppColors.white;
      borderColor = isSelected ? AppColors.primary : Colors.grey.shade300;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: isSelected && !hasAnswered ? 3 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: hasAnswered ? null : () => onSelect(value), // Disable after answer submitted
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Main icon
            Icon(
              icon,
              size: 48,
              color: hasAnswered && isSelected
                  ? AppColors.white
                  : (hasAnswered && isCorrectOption
                      ? AppColors.success
                      : AppColors.primary),
            ),
            const SizedBox(height: 8),
            // Label text
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ).copyWith(
                color: hasAnswered && isSelected
                    ? AppColors.white
                    : (hasAnswered && isCorrectOption
                        ? AppColors.success
                        : AppColors.textPrimary),
              ),
            ),
            // Feedback icon (checkmark or X)
            if (feedbackIcon != null) ...[
              const SizedBox(height: 8),
              Icon(
                feedbackIcon,
                size: 32,
                color: iconColor,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

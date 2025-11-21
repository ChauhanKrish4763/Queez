import 'package:flutter/material.dart';
import 'package:quiz_app/utils/quiz_design_system.dart';

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
        const SizedBox(width: QuizSpacing.md), // 16px spacing between buttons
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
          backgroundColor = QuizColors.correct;
          borderColor = QuizColors.correct;
          feedbackIcon = Icons.check_circle;
          iconColor = Colors.white;
        } else {
          // Incorrect answer - red background
          backgroundColor = QuizColors.incorrect;
          borderColor = QuizColors.incorrect;
          feedbackIcon = Icons.cancel;
          iconColor = Colors.white;
        }
      } else if (isCorrectOption) {
        // Show correct answer with green tint (not selected)
        backgroundColor = QuizColors.correct.withValues(alpha: 0.3);
        borderColor = QuizColors.correct;
        feedbackIcon = Icons.check_circle;
        iconColor = QuizColors.correct;
      } else {
        // Not selected, not correct - neutral
        backgroundColor = Theme.of(context).cardColor;
        borderColor = Colors.grey.shade300;
      }
    } else {
      // Not answered yet - neutral state
      backgroundColor = Theme.of(context).cardColor;
      borderColor = isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300;
    }

    return AnimatedContainer(
      duration: QuizAnimations.normal, // 300ms transition
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(QuizSpacing.lg), // 24px padding
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(QuizBorderRadius.lg), // 16px rounded corners
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
        borderRadius: BorderRadius.circular(QuizBorderRadius.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Main icon
            Icon(
              icon,
              size: 48,
              color: hasAnswered && isSelected
                  ? Colors.white
                  : (hasAnswered && isCorrectOption
                      ? QuizColors.correct
                      : Theme.of(context).primaryColor),
            ),
            const SizedBox(height: QuizSpacing.sm), // 8px spacing
            // Label text
            Text(
              label,
              style: QuizTextStyles.optionText.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: hasAnswered && isSelected
                    ? Colors.white
                    : (hasAnswered && isCorrectOption
                        ? QuizColors.correct
                        : QuizColors.textPrimary),
              ),
            ),
            // Feedback icon (checkmark or X)
            if (feedbackIcon != null) ...[
              const SizedBox(height: QuizSpacing.sm), // 8px spacing
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

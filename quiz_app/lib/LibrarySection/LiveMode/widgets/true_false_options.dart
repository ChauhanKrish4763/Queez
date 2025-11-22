import 'package:flutter/material.dart';
import 'package:quiz_app/utils/quiz_design_system.dart';

/// Widget for True/False questions in live multiplayer mode
class TrueFalseOptions extends StatelessWidget {
  final Function(int) onSelect;
  final int? selectedAnswer;
  final int? correctAnswer;
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
    return Column(
      children: [
        _buildOptionButton(
          context: context,
          label: 'TRUE',
          value: 0,
          icon: Icons.check_circle_outline,
        ),
        const SizedBox(height: QuizSpacing.lg),
        _buildOptionButton(
          context: context,
          label: 'FALSE',
          value: 1,
          icon: Icons.cancel_outlined,
        ),
      ],
    );
  }

  Widget _buildOptionButton({
    required BuildContext context,
    required String label,
    required int value,
    required IconData icon,
  }) {
    final isSelected = selectedAnswer == value;
    final isCorrectOption = correctAnswer == value;

    // Determine colors based on state
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    IconData? feedbackIcon;

    if (hasAnswered) {
      if (isSelected) {
        // User selected this option
        if (isCorrect == true) {
          // Correct answer
          backgroundColor = QuizColors.correct;
          borderColor = QuizColors.correct;
          textColor = Colors.white;
          feedbackIcon = Icons.check_circle;
        } else {
          // Incorrect answer
          backgroundColor = QuizColors.incorrect;
          borderColor = QuizColors.incorrect;
          textColor = Colors.white;
          feedbackIcon = Icons.cancel;
        }
      } else if (isCorrectOption) {
        // Show correct answer (not selected)
        backgroundColor = QuizColors.correct.withValues(alpha: 0.2);
        borderColor = QuizColors.correct;
        textColor = QuizColors.correct;
        feedbackIcon = Icons.check_circle_outline;
      } else {
        // Not selected, not correct
        backgroundColor = QuizColors.cardBackground;
        borderColor = QuizColors.divider;
        textColor = QuizColors.textSecondary;
        feedbackIcon = null;
      }
    } else {
      // Not answered yet
      backgroundColor =
          isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
              : QuizColors.cardBackground;
      borderColor =
          isSelected
              ? Theme.of(context).colorScheme.primary
              : QuizColors.divider;
      textColor =
          isSelected
              ? Theme.of(context).colorScheme.primary
              : QuizColors.textPrimary;
      feedbackIcon = null;
    }

    return AnimatedContainer(
      duration: QuizAnimations.normal,
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(QuizBorderRadius.lg),
        border: Border.all(
          color: borderColor,
          width: isSelected && !hasAnswered ? 3 : 2,
        ),
        boxShadow: [
          if (isSelected && !hasAnswered)
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: InkWell(
        onTap: hasAnswered ? null : () => onSelect(value),
        borderRadius: BorderRadius.circular(QuizBorderRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(QuizSpacing.xl),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: textColor),
              const SizedBox(width: QuizSpacing.md),
              Text(
                label,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              if (feedbackIcon != null) ...[
                const Spacer(),
                Icon(feedbackIcon, size: 32, color: textColor),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

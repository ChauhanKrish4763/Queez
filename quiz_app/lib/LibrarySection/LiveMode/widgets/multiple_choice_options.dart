import 'package:flutter/material.dart';
import 'package:quiz_app/utils/quiz_design_system.dart';

/// Widget that displays multiple choice question options for live multiplayer quiz
/// Renders all options as selectable buttons with appropriate feedback colors and icons
class MultipleChoiceOptions extends StatelessWidget {
  final List<String> options;
  final Function(String) onSelect;
  final String? selectedAnswer;
  final String? correctAnswer;
  final bool hasAnswered;
  final bool? isCorrect;

  const MultipleChoiceOptions({
    super.key,
    required this.options,
    required this.onSelect,
    this.selectedAnswer,
    this.correctAnswer,
    required this.hasAnswered,
    this.isCorrect,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: options.length,
      separatorBuilder: (context, index) => const SizedBox(height: QuizSpacing.md),
      itemBuilder: (context, index) {
        final option = options[index];
        return _buildOptionButton(
          context: context,
          option: option,
          index: index,
        );
      },
    );
  }

  Widget _buildOptionButton({
    required BuildContext context,
    required String option,
    required int index,
  }) {
    final isSelected = selectedAnswer == option;
    final isCorrectOption = correctAnswer == option;

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
        onTap: hasAnswered ? null : () => onSelect(option), // Disable after answer submitted
        borderRadius: BorderRadius.circular(QuizBorderRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(QuizSpacing.lg), // 24px padding
          child: Row(
            children: [
              // Option letter (A, B, C, D)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: hasAnswered && isSelected
                      ? Colors.white.withValues(alpha: 0.2)
                      : (hasAnswered && isCorrectOption
                          ? QuizColors.correct.withValues(alpha: 0.2)
                          : Theme.of(context).primaryColor.withValues(alpha: 0.1)),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + index), // A, B, C, D...
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: hasAnswered && isSelected
                          ? Colors.white
                          : (hasAnswered && isCorrectOption
                              ? QuizColors.correct
                              : Theme.of(context).primaryColor),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: QuizSpacing.md), // 16px spacing
              // Option text
              Expanded(
                child: Text(
                  option,
                  style: QuizTextStyles.optionText.copyWith(
                    color: hasAnswered && isSelected
                        ? Colors.white
                        : (hasAnswered && isCorrectOption
                            ? QuizColors.correct
                            : QuizColors.textPrimary),
                  ),
                ),
              ),
              // Feedback icon (checkmark or X)
              if (feedbackIcon != null) ...[
                const SizedBox(width: QuizSpacing.md), // 16px spacing
                Icon(
                  feedbackIcon,
                  size: 32,
                  color: iconColor,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

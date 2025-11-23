import 'package:flutter/material.dart';
import 'package:quiz_app/utils/color.dart';

/// Widget that displays multiple choice question options for live multiplayer quiz
/// Renders all options as selectable buttons with appropriate feedback colors and icons
class MultipleChoiceOptions extends StatelessWidget {
  final List<String> options;
  final Function(int) onSelect;
  final int? selectedAnswer;
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
      separatorBuilder: (context, index) => const SizedBox(height: 16),
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
    final isSelected = selectedAnswer == index;
    final isCorrectOption = correctAnswer == index.toString();

    // Determine background color based on answer state
    Color backgroundColor;
    Color borderColor;
    IconData? feedbackIcon;
    Color? iconColor;

    if (hasAnswered && isCorrect != null) {
      // Only show feedback after backend response (isCorrect is set)
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
      // Not answered yet OR waiting for backend response - neutral state
      backgroundColor = AppColors.white;
      borderColor = isSelected ? AppColors.primary : Colors.grey.shade300;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
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
        onTap: hasAnswered ? null : () => onSelect(index),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              // Option letter (A, B, C, D)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color:
                      hasAnswered && isCorrect != null && isSelected
                          ? AppColors.white.withValues(alpha: 0.2)
                          : (hasAnswered && isCorrect != null && isCorrectOption
                              ? AppColors.success.withValues(alpha: 0.2)
                              : AppColors.primary.withValues(alpha: 0.1)),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + index), // A, B, C, D...
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color:
                          hasAnswered && isCorrect != null && isSelected
                              ? AppColors.white
                              : (hasAnswered && isCorrect != null && isCorrectOption
                                  ? AppColors.success
                                  : AppColors.primary),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Option text
              Expanded(
                child: Text(
                  option,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ).copyWith(
                    color:
                        hasAnswered && isCorrect != null && isSelected
                            ? AppColors.white
                            : (hasAnswered && isCorrect != null && isCorrectOption
                                ? AppColors.success
                                : AppColors.textPrimary),
                  ),
                ),
              ),
              // Feedback icon (checkmark or X)
              if (feedbackIcon != null) ...[
                const SizedBox(width: 16),
                Icon(feedbackIcon, size: 32, color: iconColor),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

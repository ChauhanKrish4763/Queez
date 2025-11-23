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
    debugPrint('[MCQ Debug] Building MCQ widget - hasAnswered: $hasAnswered, selectedAnswer: $selectedAnswer, correctAnswer: $correctAnswer, isCorrect: $isCorrect');
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
    bool isCorrectOption = false;
    if (correctAnswer != null) {
      // Try parsing as index first
      final correctIndex = int.tryParse(correctAnswer!);
      if (correctIndex != null) {
        isCorrectOption = correctIndex == index;
        debugPrint('[MCQ Debug] correctAnswer: "$correctAnswer" (parsed as index: $correctIndex), option index: $index, isCorrectOption: $isCorrectOption');
      } else {
        // Fall back to text comparison (case-insensitive)
        isCorrectOption = correctAnswer!.toLowerCase() == option.toLowerCase();
        debugPrint('[MCQ Debug] correctAnswer: "$correctAnswer" (text), option: "$option", isCorrectOption: $isCorrectOption');
      }
    }
    
    debugPrint('[MCQ Debug] Option $index: isSelected=$isSelected, isCorrectOption=$isCorrectOption, hasAnswered=$hasAnswered, selectedAnswer=$selectedAnswer, correctAnswer=$correctAnswer');

    // Determine background color based on answer state
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    IconData? feedbackIcon;
    Color? iconColor;

    if (hasAnswered) {
      if (isSelected && isCorrectOption) {
        // User selected correct answer - green
        backgroundColor = AppColors.success;
        borderColor = AppColors.success;
        textColor = AppColors.white;
        feedbackIcon = Icons.check_circle;
        iconColor = AppColors.white;
      } else if (isSelected && !isCorrectOption) {
        // User selected wrong answer - red
        debugPrint('[MCQ Debug] Applying RED highlighting for wrong answer at index $index');
        backgroundColor = AppColors.error;
        borderColor = AppColors.error;
        textColor = AppColors.white;
        feedbackIcon = Icons.cancel;
        iconColor = AppColors.white;
      } else if (!isSelected && isCorrectOption) {
        debugPrint('[MCQ Debug] Applying GREEN highlighting for correct answer at index $index (not selected)');
        // Correct answer but user didn't select - light green
        backgroundColor = AppColors.success.withValues(alpha: 0.2);
        borderColor = AppColors.success;
        textColor = AppColors.success;
        feedbackIcon = Icons.check_circle_outline;
        iconColor = AppColors.success;
      } else {
        // Not selected, not correct - neutral
        backgroundColor = AppColors.white;
        borderColor = Colors.grey.shade300;
        textColor = AppColors.textPrimary;
      }
    } else {
      // Not answered yet - neutral state
      backgroundColor = AppColors.white;
      borderColor = isSelected ? AppColors.primary : Colors.grey.shade300;
      textColor = AppColors.textPrimary;
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
                      hasAnswered && (isSelected || isCorrectOption)
                          ? (isSelected
                              ? AppColors.white.withValues(alpha: 0.2)
                              : AppColors.success.withValues(alpha: 0.2))
                          : AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + index), // A, B, C, D...
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color:
                          hasAnswered && (isSelected || isCorrectOption)
                              ? (isSelected
                                  ? AppColors.white
                                  : AppColors.success)
                              : AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Option text
              Expanded(
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
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

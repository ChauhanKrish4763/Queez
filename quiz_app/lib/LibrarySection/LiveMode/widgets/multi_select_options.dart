import 'package:flutter/material.dart';
import 'package:quiz_app/utils/color.dart';

/// Widget that displays multiple choice question options with checkboxes for live multiplayer quiz
/// Allows users to select multiple answers and submit them together
class MultiSelectOptions extends StatefulWidget {
  final List<String> options;
  final Function(List<int>) onSubmit;
  final VoidCallback? onNextQuestion;
  final bool hasAnswered;
  final List<int>? selectedAnswers;
  final List<int>? correctAnswers;
  final bool? isCorrect;

  const MultiSelectOptions({
    super.key,
    required this.options,
    required this.onSubmit,
    this.onNextQuestion,
    required this.hasAnswered,
    this.selectedAnswers,
    this.correctAnswers,
    this.isCorrect,
  });

  @override
  State<MultiSelectOptions> createState() => _MultiSelectOptionsState();
}

class _MultiSelectOptionsState extends State<MultiSelectOptions> {
  late Set<int> _selectedIndices;

  @override
  void initState() {
    super.initState();
    _selectedIndices = widget.selectedAnswers?.toSet() ?? {};
  }

  void _toggleOption(int index) {
    if (widget.hasAnswered) return;

    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
    });
  }

  void _handleSubmit() {
    if (_selectedIndices.isNotEmpty && !widget.hasAnswered) {
      widget.onSubmit(_selectedIndices.toList()..sort());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Options list
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.options.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final option = widget.options[index];
            return _buildOptionButton(
              context: context,
              option: option,
              index: index,
            );
          },
        ),
        
        const SizedBox(height: 24),
        
        // Submit button
        ElevatedButton(
          onPressed: (_selectedIndices.isNotEmpty && !widget.hasAnswered) 
              ? _handleSubmit 
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            disabledBackgroundColor: AppColors.disabledBackground,
            disabledForegroundColor: AppColors.textDisabled,
            padding: const EdgeInsets.symmetric(vertical: 16),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.hasAnswered && widget.isCorrect != null) ...[
                Icon(
                  widget.isCorrect! ? Icons.check_circle : Icons.cancel,
                  size: 24,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                widget.hasAnswered
                    ? 'Submitted'
                    : (_selectedIndices.isEmpty 
                        ? 'Select at least one option' 
                        : 'Submit Options (${_selectedIndices.length} selected)'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        
        // Next Question Button (after submission)
        if (widget.hasAnswered && widget.onNextQuestion != null)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: ElevatedButton(
              onPressed: widget.onNextQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Next Question',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildOptionButton({
    required BuildContext context,
    required String option,
    required int index,
  }) {
    final isSelected = _selectedIndices.contains(index);
    final isCorrectOption = widget.correctAnswers?.contains(index) ?? false;
    final wasSelected = widget.selectedAnswers?.contains(index) ?? false;

    // Determine background color based on answer state
    Color backgroundColor;
    Color borderColor;
    Color checkboxColor;
    IconData? feedbackIcon;
    Color? iconColor;

    if (widget.hasAnswered) {
      // Check if this option was selected by the user
      final userSelected = wasSelected;
      
      if (isCorrectOption && userSelected) {
        // User selected this AND it's correct - solid green
        backgroundColor = AppColors.success;
        borderColor = AppColors.success;
        checkboxColor = AppColors.white;
        feedbackIcon = Icons.check_circle;
        iconColor = AppColors.white;
      } else if (isCorrectOption && !userSelected) {
        // User DIDN'T select but it's correct - light green with border (missed correct answer)
        backgroundColor = AppColors.success.withValues(alpha: 0.2);
        borderColor = AppColors.success;
        checkboxColor = AppColors.success;
        feedbackIcon = Icons.check_circle_outline;
        iconColor = AppColors.success;
      } else if (!isCorrectOption && userSelected) {
        // User selected this BUT it's wrong - RED
        backgroundColor = AppColors.error;
        borderColor = AppColors.error;
        checkboxColor = AppColors.white;
        feedbackIcon = Icons.cancel;
        iconColor = AppColors.white;
      } else {
        // Not selected, not correct - neutral
        backgroundColor = AppColors.white;
        borderColor = Colors.grey.shade300;
        checkboxColor = Colors.grey.shade400;
      }
    } else {
      // Not answered yet - neutral state
      backgroundColor = AppColors.white;
      borderColor = isSelected ? AppColors.primary : Colors.grey.shade300;
      checkboxColor = isSelected ? AppColors.primary : Colors.grey.shade400;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: isSelected && !widget.hasAnswered ? 3 : 2,
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
        onTap: widget.hasAnswered ? null : () => _toggleOption(index),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Checkbox
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isSelected || (widget.hasAnswered && wasSelected)
                      ? checkboxColor
                      : Colors.transparent,
                  border: Border.all(
                    color: checkboxColor,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: (isSelected || (widget.hasAnswered && wasSelected))
                    ? Icon(
                        Icons.check,
                        size: 20,
                        color: widget.hasAnswered && wasSelected
                            ? (isCorrectOption ? AppColors.white : AppColors.white)
                            : AppColors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              
              // Option letter (A, B, C, D)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: widget.hasAnswered && wasSelected
                      ? AppColors.white.withValues(alpha: 0.2)
                      : (widget.hasAnswered && isCorrectOption
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
                      color: widget.hasAnswered && wasSelected
                          ? AppColors.white
                          : (widget.hasAnswered && isCorrectOption
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
                    color: widget.hasAnswered && wasSelected
                        ? AppColors.white
                        : (widget.hasAnswered && isCorrectOption
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

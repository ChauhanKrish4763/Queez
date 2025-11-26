import 'package:flutter/material.dart';
import 'package:quiz_app/utils/color.dart';

class TrueFalseOptions extends StatefulWidget {
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
  State<TrueFalseOptions> createState() => _TrueFalseOptionsState();
}

class _TrueFalseOptionsState extends State<TrueFalseOptions> {
  int? _localSelectedValue;
  bool _waitingForResult = false;

  void _handleTap(int value) {
    if (_waitingForResult || widget.hasAnswered) return;
    
    debugPrint('📝 TRUE_FALSE - User tapped: ${value == 0 ? "TRUE" : "FALSE"}');
    setState(() {
      _localSelectedValue = value;
      _waitingForResult = true;
    });
    widget.onSelect(value);
  }

  @override
  void didUpdateWidget(TrueFalseOptions oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // When we get the result back from backend
    if (widget.correctAnswer != null && oldWidget.correctAnswer == null) {
      debugPrint('📝 TRUE_FALSE - Got result from backend');
      setState(() {
        _waitingForResult = false;
      });
    }
    
    // Reset when moving to new question (correctAnswer becomes null again)
    if (widget.correctAnswer == null && oldWidget.correctAnswer != null) {
      debugPrint('📝 TRUE_FALSE - New question, resetting');
      setState(() {
        _localSelectedValue = null;
        _waitingForResult = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveSelectedValue = widget.selectedAnswer ?? _localSelectedValue;
    final hasResult = widget.correctAnswer != null;
    
    return Column(
      children: [
        _buildOptionButton(
          label: 'TRUE',
          value: 0,
          effectiveSelectedValue: effectiveSelectedValue,
          hasResult: hasResult,
        ),
        const SizedBox(height: 16),
        _buildOptionButton(
          label: 'FALSE',
          value: 1,
          effectiveSelectedValue: effectiveSelectedValue,
          hasResult: hasResult,
        ),
      ],
    );
  }

  Widget _buildOptionButton({
    required String label,
    required int value,
    required int? effectiveSelectedValue,
    required bool hasResult,
  }) {
    final isSelected = effectiveSelectedValue == value;
    final isCorrectOption = widget.correctAnswer == value;
    final isDisabled = _waitingForResult || widget.hasAnswered;
    
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    IconData? feedbackIcon;
    
    if (hasResult) {
      // Show final result
      if (isCorrectOption) {
        backgroundColor = AppColors.success;
        borderColor = AppColors.success;
        textColor = Colors.white;
        feedbackIcon = Icons.check_circle;
      } else if (isSelected && !isCorrectOption) {
        backgroundColor = const Color(0xFFE53935);
        borderColor = const Color(0xFFE53935);
        textColor = Colors.white;
        feedbackIcon = Icons.cancel;
      } else {
        backgroundColor = AppColors.white;
        borderColor = Colors.grey.shade300;
        textColor = AppColors.textPrimary;
        feedbackIcon = null;
      }
    } else if (_waitingForResult && isSelected) {
      // Waiting - use BLUE to indicate selection (not green)
      backgroundColor = AppColors.info;
      borderColor = AppColors.info;
      textColor = Colors.white;
      feedbackIcon = null;
    } else {
      backgroundColor = AppColors.white;
      borderColor = Colors.grey.shade300;
      textColor = AppColors.textPrimary;
      feedbackIcon = null;
    }

    return GestureDetector(
      onTap: isDisabled ? null : () => _handleTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2.5 : 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
                letterSpacing: 1.5,
              ),
            ),
            if (feedbackIcon != null) ...[
              const SizedBox(width: 16),
              Icon(feedbackIcon, color: Colors.white, size: 28),
            ],
          ],
        ),
      ),
    );
  }
}

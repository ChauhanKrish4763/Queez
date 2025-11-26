import 'package:flutter/material.dart';
import 'package:quiz_app/utils/color.dart';

class MultipleChoiceOptions extends StatefulWidget {
  final List options;
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
  State<MultipleChoiceOptions> createState() => _MultipleChoiceOptionsState();
}

class _MultipleChoiceOptionsState extends State<MultipleChoiceOptions> {
  int? _localSelectedIndex;
  bool _waitingForResult = false;

  void _handleOptionTap(int index) {
    if (_waitingForResult || widget.hasAnswered) return;
    
    debugPrint('📝 SINGLE_CHOICE - User tapped option $index');
    setState(() {
      _localSelectedIndex = index;
      _waitingForResult = true;
    });
    widget.onSelect(index);
  }

  @override
  void didUpdateWidget(MultipleChoiceOptions oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // When we get the result back from backend
    if (widget.correctAnswer != null && oldWidget.correctAnswer == null) {
      debugPrint('📝 SINGLE_CHOICE - Got result from backend');
      setState(() {
        _waitingForResult = false;
      });
    }
    
    // Reset when question changes (new options list)
    if (widget.options.length != oldWidget.options.length ||
        (widget.options.isNotEmpty && oldWidget.options.isNotEmpty && 
         widget.options[0] != oldWidget.options[0])) {
      debugPrint('📝 SINGLE_CHOICE - New question detected, resetting');
      setState(() {
        _localSelectedIndex = null;
        _waitingForResult = false;
      });
    }
  }

  int? _getCorrectAnswerIndex() {
    if (widget.correctAnswer == null) return null;
    final parsed = int.tryParse(widget.correctAnswer!);
    if (parsed != null) return parsed;
    for (int i = 0; i < widget.options.length; i++) {
      if (widget.options[i].toString() == widget.correctAnswer) {
        return i;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveSelectedIndex = widget.selectedAnswer ?? _localSelectedIndex;
    final correctIndex = _getCorrectAnswerIndex();
    final hasResult = widget.correctAnswer != null;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.options.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final isSelected = effectiveSelectedIndex == index;
        final isCorrectOption = correctIndex == index;
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
            textColor = Colors.black;
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
          textColor = Colors.black;
          feedbackIcon = null;
        }

        return GestureDetector(
          onTap: isDisabled ? null : () => _handleOptionTap(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border.all(
                color: borderColor,
                width: isSelected ? 2.5 : 1.5,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.2)
                        : AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      String.fromCharCode(65 + index),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    widget.options[index].toString(),
                    style: TextStyle(
                      color: textColor,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (feedbackIcon != null) ...[
                  const SizedBox(width: 12),
                  Icon(feedbackIcon, color: Colors.white, size: 28),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

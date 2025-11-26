import 'package:flutter/material.dart';
import 'package:quiz_app/utils/color.dart';

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
  Set<int> _localSelectedIndices = {};
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _localSelectedIndices = {};
  }

  @override
  void didUpdateWidget(MultiSelectOptions oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Reset when question changes (new options)
    if (widget.options.length != oldWidget.options.length ||
        (widget.options.isNotEmpty && oldWidget.options.isNotEmpty && 
         widget.options[0] != oldWidget.options[0])) {
      debugPrint('📝 MULTI_SELECT - New question detected, resetting');
      setState(() {
        _localSelectedIndices = {};
        _submitted = false;
      });
    }
    
    // Also reset if hasAnswered goes from true to false (new question)
    if (!widget.hasAnswered && oldWidget.hasAnswered) {
      debugPrint('📝 MULTI_SELECT - hasAnswered changed to false, resetting');
      setState(() {
        _localSelectedIndices = {};
        _submitted = false;
      });
    }
  }

  void _toggleOption(int index) {
    if (widget.hasAnswered || _submitted) return;

    setState(() {
      if (_localSelectedIndices.contains(index)) {
        _localSelectedIndices.remove(index);
      } else {
        _localSelectedIndices.add(index);
      }
    });
  }

  void _handleSubmit() {
    if (_localSelectedIndices.isNotEmpty && !widget.hasAnswered && !_submitted) {
      debugPrint('📝 MULTI_SELECT - Submitting: ${_localSelectedIndices.toList()..sort()}');
      setState(() {
        _submitted = true;
      });
      widget.onSubmit(_localSelectedIndices.toList()..sort());
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasResult = widget.correctAnswers != null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.options.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _buildOptionButton(index: index, hasResult: hasResult);
          },
        ),
        const SizedBox(height: 20),
        
        // Submit button (before submission)
        if (!widget.hasAnswered && !_submitted)
          ElevatedButton(
            onPressed: _localSelectedIndices.isNotEmpty ? _handleSubmit : null,
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
            child: Text(
              _localSelectedIndices.isEmpty 
                  ? 'Select at least one option' 
                  : 'Submit (${_localSelectedIndices.length} selected)',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        
        // Waiting for result
        if (_submitted && !hasResult)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.info, width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.info,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Checking answers...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.info,
                  ),
                ),
              ],
            ),
          ),
        
        // Result feedback
        if (hasResult)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.isCorrect == true 
                  ? AppColors.success.withValues(alpha: 0.1)
                  : const Color(0xFFE53935).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.isCorrect == true 
                    ? AppColors.success 
                    : const Color(0xFFE53935),
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.isCorrect == true ? Icons.check_circle : Icons.cancel,
                  color: widget.isCorrect == true 
                      ? AppColors.success 
                      : const Color(0xFFE53935),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  widget.isCorrect == true ? 'Correct!' : 'Incorrect',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.isCorrect == true 
                        ? AppColors.success 
                        : const Color(0xFFE53935),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildOptionButton({required int index, required bool hasResult}) {
    final isLocalSelected = _localSelectedIndices.contains(index);
    final isCorrectOption = widget.correctAnswers?.contains(index) ?? false;
    final wasSubmittedSelected = widget.selectedAnswers?.contains(index) ?? false;
    
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    IconData? feedbackIcon;
    bool showCheckbox;

    if (hasResult) {
      // Show final result - use backend's selectedAnswers
      showCheckbox = wasSubmittedSelected;
      if (isCorrectOption && wasSubmittedSelected) {
        backgroundColor = AppColors.success;
        borderColor = AppColors.success;
        textColor = Colors.white;
        feedbackIcon = Icons.check_circle;
      } else if (isCorrectOption && !wasSubmittedSelected) {
        backgroundColor = AppColors.success.withValues(alpha: 0.15);
        borderColor = AppColors.success;
        textColor = AppColors.success;
        feedbackIcon = Icons.check_circle_outline;
      } else if (!isCorrectOption && wasSubmittedSelected) {
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
    } else if (_submitted) {
      // Submitted, waiting for result - use BLUE
      showCheckbox = isLocalSelected;
      if (isLocalSelected) {
        backgroundColor = AppColors.info.withValues(alpha: 0.1);
        borderColor = AppColors.info;
        textColor = AppColors.textPrimary;
        feedbackIcon = null;
      } else {
        backgroundColor = AppColors.white;
        borderColor = Colors.grey.shade300;
        textColor = AppColors.textPrimary;
        feedbackIcon = null;
      }
    } else {
      // Not submitted yet - local selection
      showCheckbox = isLocalSelected;
      backgroundColor = AppColors.white;
      borderColor = isLocalSelected ? AppColors.info : Colors.grey.shade300;
      textColor = AppColors.textPrimary;
      feedbackIcon = null;
    }

    return GestureDetector(
      onTap: (widget.hasAnswered || _submitted) ? null : () => _toggleOption(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          children: [
            // Checkbox
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: showCheckbox
                    ? (hasResult && wasSubmittedSelected
                        ? Colors.white.withValues(alpha: 0.3)
                        : AppColors.info)
                    : Colors.transparent,
                border: Border.all(
                  color: showCheckbox
                      ? (hasResult ? Colors.white.withValues(alpha: 0.5) : AppColors.info)
                      : Colors.grey.shade400,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: showCheckbox
                  ? const Icon(Icons.check, size: 18, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 14),
            
            // Option letter
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: (hasResult && (wasSubmittedSelected || isCorrectOption))
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
            
            // Option text
            Expanded(
              child: Text(
                widget.options[index],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
            
            if (feedbackIcon != null) ...[
              const SizedBox(width: 12),
              Icon(
                feedbackIcon,
                size: 28,
                color: (hasResult && wasSubmittedSelected) || (hasResult && isCorrectOption && !wasSubmittedSelected)
                    ? (isCorrectOption ? (wasSubmittedSelected ? Colors.white : AppColors.success) : Colors.white)
                    : Colors.grey,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

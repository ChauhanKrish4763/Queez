import 'package:flutter/material.dart';
import 'package:quiz_app/utils/quiz_design_system.dart';

/// Widget that displays a text input field for single answer questions in live multiplayer quiz
/// Allows participants to type free-form answers with visual feedback after submission
class SingleAnswerInput extends StatefulWidget {
  final Function(String) onSubmit;
  final bool hasAnswered;
  final bool? isCorrect;

  const SingleAnswerInput({
    super.key,
    required this.onSubmit,
    required this.hasAnswered,
    this.isCorrect,
  });

  @override
  State<SingleAnswerInput> createState() => _SingleAnswerInputState();
}

class _SingleAnswerInputState extends State<SingleAnswerInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_controller.text.trim().isNotEmpty && !widget.hasAnswered) {
      widget.onSubmit(_controller.text.trim());
      _focusNode.unfocus(); // Dismiss keyboard
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine border color based on answer state
    Color borderColor;
    if (widget.hasAnswered) {
      if (widget.isCorrect == true) {
        borderColor = QuizColors.correct;
      } else if (widget.isCorrect == false) {
        borderColor = QuizColors.incorrect;
      } else {
        borderColor = Colors.grey.shade300;
      }
    } else {
      borderColor = Theme.of(context).primaryColor.withValues(alpha: 0.5);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Text input field
        AnimatedContainer(
          duration: QuizAnimations.normal, // 300ms transition
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: widget.hasAnswered
                ? Colors.grey.shade100
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(QuizBorderRadius.lg), // 16px rounded corners
            border: Border.all(
              color: borderColor,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: !widget.hasAnswered, // Disable input after submission
                  style: QuizTextStyles.optionText,
                  decoration: InputDecoration(
                    hintText: 'Type your answer here...',
                    hintStyle: QuizTextStyles.optionText.copyWith(
                      color: QuizColors.textSecondary,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(QuizSpacing.lg), // 24px padding
                  ),
                  onSubmitted: (_) => _handleSubmit(),
                  textInputAction: TextInputAction.done,
                ),
              ),
              // Feedback icon (checkmark or X) after submission
              if (widget.hasAnswered && widget.isCorrect != null) ...[
                Padding(
                  padding: const EdgeInsets.only(right: QuizSpacing.md), // 16px right padding
                  child: Icon(
                    widget.isCorrect! ? Icons.check_circle : Icons.cancel,
                    size: 32,
                    color: widget.isCorrect! ? QuizColors.correct : QuizColors.incorrect,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: QuizSpacing.md), // 16px spacing
        // Submit button
        ElevatedButton(
          onPressed: widget.hasAnswered ? null : _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade300,
            disabledForegroundColor: Colors.grey.shade600,
            padding: const EdgeInsets.symmetric(
              vertical: QuizSpacing.md, // 16px vertical padding
              horizontal: QuizSpacing.xl, // 32px horizontal padding
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(QuizBorderRadius.lg), // 16px rounded corners
            ),
            elevation: widget.hasAnswered ? 0 : 2,
          ),
          child: Text(
            widget.hasAnswered ? 'Submitted' : 'Submit Answer',
            style: QuizTextStyles.optionText.copyWith(
              color: widget.hasAnswered ? Colors.grey.shade600 : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

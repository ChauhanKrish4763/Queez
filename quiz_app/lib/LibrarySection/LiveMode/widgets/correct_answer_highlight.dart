import 'package:flutter/material.dart';
import 'package:quiz_app/utils/quiz_design_system.dart';

/// Widget that displays the correct answer with a distinct green highlight
/// and shows a countdown timer before auto-advancing to the next question.
/// 
/// This widget is shown after answer feedback is dismissed to give participants
/// time to see and process the correct answer before moving on.
class CorrectAnswerHighlight extends StatefulWidget {
  /// The correct answer to display (can be index, text, or other format)
  final dynamic correctAnswer;
  
  /// Initial countdown duration in seconds (default: 2)
  final int countdown;
  
  /// Callback invoked when countdown reaches 0
  final VoidCallback onCountdownComplete;

  const CorrectAnswerHighlight({
    super.key,
    required this.correctAnswer,
    this.countdown = 2,
    required this.onCountdownComplete,
  });

  @override
  State<CorrectAnswerHighlight> createState() => _CorrectAnswerHighlightState();
}

class _CorrectAnswerHighlightState extends State<CorrectAnswerHighlight>
    with SingleTickerProviderStateMixin {
  late int _remainingSeconds;
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.countdown;
    
    // Create animation controller for smooth color transition
    _controller = AnimationController(
      duration: QuizAnimations.normal,
      vsync: this,
    );
    
    // Animate from a lighter green to the full correct green
    _colorAnimation = ColorTween(
      begin: QuizColors.correct.withValues(alpha: 0.3),
      end: QuizColors.correct,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    // Start the color animation
    _controller.forward();
    
    // Start countdown timer
    _startCountdown();
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      
      setState(() {
        _remainingSeconds--;
      });
      
      if (_remainingSeconds > 0) {
        _startCountdown();
      } else {
        // Countdown complete, invoke callback
        widget.onCountdownComplete();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(QuizSpacing.lg),
          decoration: BoxDecoration(
            color: _colorAnimation.value,
            borderRadius: BorderRadius.circular(QuizBorderRadius.lg),
            boxShadow: [
              BoxShadow(
                color: QuizColors.correct.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Correct answer label
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: QuizSpacing.sm),
                  const Text(
                    'Correct Answer',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: QuizSpacing.md),
              
              // Display the correct answer
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: QuizSpacing.lg,
                  vertical: QuizSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(QuizBorderRadius.md),
                ),
                child: Text(
                  _formatAnswer(widget.correctAnswer),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: QuizSpacing.lg),
              
              // Countdown timer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.timer,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: QuizSpacing.sm),
                  Text(
                    'Next question in $_remainingSeconds...',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Format the answer for display
  /// Handles different answer types (index, text, boolean, etc.)
  String _formatAnswer(dynamic answer) {
    if (answer == null) return 'N/A';
    
    // If it's a boolean (for True/False questions)
    if (answer is bool) {
      return answer ? 'True' : 'False';
    }
    
    // If it's a number (option index), convert to letter (0 -> A, 1 -> B, etc.)
    if (answer is int) {
      // Check if it's a reasonable index for letter conversion
      if (answer >= 0 && answer < 26) {
        return String.fromCharCode(65 + answer); // 65 is ASCII for 'A'
      }
      return answer.toString();
    }
    
    // Otherwise, return as string
    return answer.toString();
  }
}

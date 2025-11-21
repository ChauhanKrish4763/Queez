import 'package:flutter/material.dart';
import 'package:quiz_app/utils/quiz_design_system.dart';

/// Controller for managing smooth transitions between quiz questions
class TransitionAnimationController {
  /// Transitions to the next question with fade animations
  /// 
  /// This method:
  /// 1. Fades out the current question (200ms)
  /// 2. Shows a transition overlay with loading indicator
  /// 3. Waits 400ms for the transition
  /// 4. Calls onComplete callback to load the next question
  /// 5. Fades in the new question
  static Future<void> transitionToNextQuestion({
    required BuildContext context,
    required VoidCallback onComplete,
  }) async {
    // Fade out current question
    await Future.delayed(QuizAnimations.fast);
    
    // Show transition overlay
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => const QuestionTransitionOverlay(),
    );
    
    // Wait for transition
    await Future.delayed(QuizAnimations.slow);
    
    // Load next question
    onComplete();
    
    // Close the overlay (fade in new question happens automatically)
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }
}

/// Overlay widget shown during question transitions
class QuestionTransitionOverlay extends StatelessWidget {
  const QuestionTransitionOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: QuizSpacing.md),
            const Text(
              'Next Question...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

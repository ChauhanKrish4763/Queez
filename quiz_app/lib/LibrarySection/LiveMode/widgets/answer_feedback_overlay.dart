import 'package:flutter/material.dart';
import 'package:quiz_app/utils/quiz_design_system.dart';
import 'package:quiz_app/LibrarySection/LiveMode/widgets/points_earned_popup.dart';

/// Overlay component that displays immediate visual feedback after answer submission
/// Shows whether the answer was correct or incorrect with animations
/// Includes points earned popup for correct answers
class AnswerFeedbackOverlay extends StatefulWidget {
  final bool isCorrect;
  final int pointsEarned;
  final VoidCallback onComplete;

  const AnswerFeedbackOverlay({
    super.key,
    required this.isCorrect,
    required this.pointsEarned,
    required this.onComplete,
  });

  @override
  State<AnswerFeedbackOverlay> createState() => _AnswerFeedbackOverlayState();
}

class _AnswerFeedbackOverlayState extends State<AnswerFeedbackOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Create AnimationController with 600ms duration
    _controller = AnimationController(
      duration: QuizAnimations.feedback,
      vsync: this,
    );

    // Create scale animation (0.0 to 1.0) with elasticOut curve
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    // Create fade animation (0.0 to 1.0) with easeIn curve
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    // Start animation
    _controller.forward();

    // Auto-dismiss after 2 seconds by calling onComplete
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        widget.onComplete();
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
    final backgroundColor = widget.isCorrect ? QuizColors.correct : QuizColors.incorrect;
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(QuizSpacing.xl),
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: backgroundColor.withValues(alpha: 0.5),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Show checkmark icon for correct, X icon for incorrect (size 80)
                  Icon(
                    widget.isCorrect ? Icons.check : Icons.close,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  // Display "Correct!" or "Incorrect" text
                  Text(
                    widget.isCorrect ? 'Correct!' : 'Incorrect',
                    style: QuizTextStyles.feedbackText,
                  ),
                  // Include PointsEarnedPopup for correct answers
                  if (widget.isCorrect) ...[
                    const SizedBox(height: 8),
                    PointsEarnedPopup(points: widget.pointsEarned),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

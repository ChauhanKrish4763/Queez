import 'package:flutter/material.dart';
import 'package:quiz_app/utils/quiz_design_system.dart';

/// Animated score counter widget that smoothly animates from old score to new score
/// 
/// This widget provides a smooth counting animation when the score changes,
/// making score updates more engaging and noticeable to users.
/// 
/// Example usage:
/// ```dart
/// AnimatedScoreCounter(
///   score: 1500,
///   style: QuizTextStyles.scoreText,
/// )
/// ```
class AnimatedScoreCounter extends StatefulWidget {
  /// The current score to display
  final int score;
  
  /// The text style to apply to the score display
  final TextStyle style;

  const AnimatedScoreCounter({
    super.key,
    required this.score,
    required this.style,
  });

  @override
  State<AnimatedScoreCounter> createState() => _AnimatedScoreCounterState();
}

class _AnimatedScoreCounterState extends State<AnimatedScoreCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _scoreAnimation;
  int _previousScore = 0;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller with 800ms duration
    _controller = AnimationController(
      duration: QuizAnimations.counter,
      vsync: this,
    );
    
    // Set initial previous score to current score (no animation on first render)
    _previousScore = widget.score;
    
    // Set up the initial animation
    _updateAnimation();
  }

  @override
  void didUpdateWidget(AnimatedScoreCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // When score prop changes, update animation and restart
    if (oldWidget.score != widget.score) {
      _previousScore = oldWidget.score;
      _updateAnimation();
      _controller.forward(from: 0);
    }
  }

  /// Updates the animation to tween from previous score to new score
  void _updateAnimation() {
    _scoreAnimation = IntTween(
      begin: _previousScore,
      end: widget.score,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scoreAnimation,
      builder: (context, child) {
        return Text(
          _scoreAnimation.value.toString(),
          style: widget.style,
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

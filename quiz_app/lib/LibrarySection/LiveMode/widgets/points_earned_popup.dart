import 'package:flutter/material.dart';
import 'package:quiz_app/utils/quiz_design_system.dart';

/// Popup component that displays points earned with animation
/// Shows "+{points}" text with slide-up and fade-out effects
class PointsEarnedPopup extends StatefulWidget {
  final int points;

  const PointsEarnedPopup({
    super.key,
    required this.points,
  });

  @override
  State<PointsEarnedPopup> createState() => _PointsEarnedPopupState();
}

class _PointsEarnedPopupState extends State<PointsEarnedPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Create AnimationController with 1000ms duration
    _controller = AnimationController(
      duration: QuizAnimations.transition,
      vsync: this,
    );

    // Create slide animation (Offset(0,0) to Offset(0,-0.5)) with easeOut curve
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, -0.5),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    // Create fade animation (1.0 to 0.0) starting at 50% progress
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    // Auto-start animation in initState
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Text(
              '+${widget.points}',
              style: QuizTextStyles.pointsText.copyWith(
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

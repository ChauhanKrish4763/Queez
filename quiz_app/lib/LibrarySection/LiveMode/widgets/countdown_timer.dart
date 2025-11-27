import 'package:flutter/material.dart';
import 'package:quiz_app/utils/color.dart';

class CountdownTimer extends StatefulWidget {
  final int timeRemaining;
  final int timeLimit;
  final bool hasAnswered;

  const CountdownTimer({
    super.key,
    required this.timeRemaining,
    required this.timeLimit,
    this.hasAnswered = false,
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  double _previousProgress = 1.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _previousProgress = widget.timeLimit > 0 
        ? widget.timeRemaining / widget.timeLimit 
        : 0.0;
    _progressAnimation = Tween<double>(
      begin: _previousProgress,
      end: _previousProgress,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));
  }

  @override
  void didUpdateWidget(CountdownTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.timeRemaining != widget.timeRemaining) {
      final newProgress = widget.timeLimit > 0 
          ? widget.timeRemaining / widget.timeLimit 
          : 0.0;
      _progressAnimation = Tween<double>(
        begin: _previousProgress,
        end: newProgress,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.linear,
      ));
      _previousProgress = newProgress;
      _animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.timeLimit > 0 
        ? widget.timeRemaining / widget.timeLimit 
        : 0.0;
    final isLowTime = widget.timeRemaining <= 5;
    final isCriticalTime = widget.timeRemaining <= 3;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _getTimerColor(progress, isLowTime).withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 20,
                    color: _getTimerColor(progress, isLowTime),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Time',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: isCriticalTime ? 28 : 24,
                  fontWeight: FontWeight.w700,
                  color: _getTimerColor(progress, isLowTime),
                ),
                child: Text('${widget.timeRemaining}s'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return LinearProgressIndicator(
                  value: _progressAnimation.value,
                  backgroundColor: AppColors.background,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getTimerColor(progress, isLowTime),
                  ),
                  minHeight: 6,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getTimerColor(double progress, bool isLowTime) {
    if (isLowTime) return const Color(0xFFE53935); // Red
    if (progress > 0.6) return const Color(0xFF4CAF50); // Green
    if (progress > 0.3) return const Color(0xFFFF9800); // Orange
    return const Color(0xFFE53935); // Red
  }
}

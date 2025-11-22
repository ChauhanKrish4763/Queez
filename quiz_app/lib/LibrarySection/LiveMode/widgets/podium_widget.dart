import 'package:flutter/material.dart';
import 'package:quiz_app/utils/quiz_design_system.dart';
import 'package:quiz_app/utils/color.dart';

/// Beautiful animated podium widget for top 3 winners
class PodiumWidget extends StatefulWidget {
  final List<Map<String, dynamic>> topThree;
  final String currentUserId;

  const PodiumWidget({
    super.key,
    required this.topThree,
    required this.currentUserId,
  });

  @override
  State<PodiumWidget> createState() => _PodiumWidgetState();
}

class _PodiumWidgetState extends State<PodiumWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _podiumAnimations;
  late List<Animation<double>> _fadeAnimations;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Staggered animations for each podium position
    _podiumAnimations = [
      // 2nd place (left) - starts at 0.2s
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.2, 0.6, curve: Curves.elasticOut),
        ),
      ),
      // 1st place (center) - starts at 0.0s
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
        ),
      ),
      // 3rd place (right) - starts at 0.4s
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.4, 0.8, curve: Curves.elasticOut),
        ),
      ),
    ];

    _fadeAnimations = _podiumAnimations
        .map(
          (anim) => Tween<double>(begin: 0.0, end: 1.0).animate(anim),
        )
        .toList();

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ensure we have exactly 3 entries (pad with nulls if needed)
    final List<Map<String, dynamic>?> podiumData = [
      widget.topThree.length > 1 ? widget.topThree[1] : null, // 2nd
      widget.topThree.isNotEmpty ? widget.topThree[0] : null, // 1st
      widget.topThree.length > 2 ? widget.topThree[2] : null, // 3rd
    ];

    final heights = [120.0, 160.0, 100.0]; // Heights for 2nd, 1st, 3rd
    final colors = [QuizColors.silver, QuizColors.gold, QuizColors.bronze];
    final ranks = [2, 1, 3];

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(3, (index) {
            final data = podiumData[index];
            if (data == null) return const SizedBox(width: 90);

            final isCurrentUser = data['user_id'] == widget.currentUserId;
            final height = heights[index] * _podiumAnimations[index].value;
            // Clamp opacity between 0.0 and 1.0 to fix assertion error
            final opacity = _fadeAnimations[index].value.clamp(0.0, 1.0);

            return Opacity(
              opacity: opacity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Trophy/Medal Icon
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors[index].withValues(alpha: 0.2),
                        border: Border.all(
                          color: colors[index],
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colors[index].withValues(alpha: 0.4),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.emoji_events,
                        color: colors[index],
                        size: 35,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Username
                    SizedBox(
                      width: 90,
                      child: Text(
                        data['username'] ?? 'Unknown',
                        style: TextStyle(
                          color: isCurrentUser
                              ? AppColors.primary
                              : QuizColors.textPrimary,
                          fontWeight:
                              isCurrentUser ? FontWeight.bold : FontWeight.w600,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Score
                    Text(
                      '${data['score']} pts',
                      style: TextStyle(
                        color: colors[index],
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Podium
                    Container(
                      width: 90,
                      height: height,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            colors[index].withValues(alpha: 0.8),
                            colors[index].withValues(alpha: 0.6),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        border: Border.all(
                          color: colors[index],
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colors[index].withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '${ranks[index]}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
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
  void didUpdateWidget(PodiumWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Check if rankings changed
    bool rankingsChanged = false;
    if (oldWidget.topThree.length != widget.topThree.length) {
      rankingsChanged = true;
    } else {
      for (int i = 0; i < widget.topThree.length; i++) {
        if (oldWidget.topThree[i]['user_id'] != widget.topThree[i]['user_id'] ||
            oldWidget.topThree[i]['score'] != widget.topThree[i]['score']) {
          rankingsChanged = true;
          break;
        }
      }
    }
    
    // Re-animate if rankings changed
    if (rankingsChanged) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.topThree.isEmpty) return const SizedBox.shrink();

    // Prepare podium data: [2nd, 1st, 3rd]
    final List<Map<String, dynamic>?> podiumData = [
      widget.topThree.length > 1 ? widget.topThree[1] : null, // 2nd place
      widget.topThree.isNotEmpty ? widget.topThree[0] : null, // 1st place
      widget.topThree.length > 2 ? widget.topThree[2] : null, // 3rd place
    ];

    final heights = [80.0, 112.0, 64.0]; // Heights for 2nd, 1st, 3rd
    final colors = [
      AppColors.secondary, // sage green for 2nd
      AppColors.primary, // forest green for 1st
      AppColors.accentBright, // bright green for 3rd
    ];
    final ranks = [2, 1, 3];

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(3, (index) {
            final data = podiumData[index];
            if (data == null) {
              return const SizedBox(width: 80);
            }

            final isCurrentUser = data['user_id'] == widget.currentUserId;
            final baseHeight = heights[index];
            final height = baseHeight * _podiumAnimations[index].value;
            final opacity = _fadeAnimations[index].value.clamp(0.0, 1.0);
            final color = colors[index];
            final rank = ranks[index];
            final width = index == 1 ? 80.0 : 64.0; // 1st place wider

            return Opacity(
              opacity: opacity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Podium Bar
                    Container(
                      width: width,
                      height: height,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                      ),
                      child: Center(
                        child:
                            rank == 1
                                ? const Icon(
                                  Icons.emoji_events,
                                  color: AppColors.white,
                                  size: 32,
                                )
                                : Text(
                                  '$rank',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.white,
                                  ),
                                ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Name
                    SizedBox(
                      width: width,
                      child: Text(
                        data['username'] ?? 'Unknown',
                        style: TextStyle(
                          fontSize: rank == 1 ? 13 : 11,
                          fontWeight:
                              isCurrentUser ? FontWeight.bold : FontWeight.w500,
                          color: AppColors.textPrimary,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),

                    // Points
                    Text(
                      '${data['score']}',
                      style: TextStyle(
                        fontSize: rank == 1 ? 14 : 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
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

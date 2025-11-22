import 'package:flutter/material.dart';
import 'package:quiz_app/utils/quiz_design_system.dart';

/// Animated leaderboard entry component that displays participant rank, username, and score
/// with smooth animations for rank changes and special styling for top 3 positions
class AnimatedLeaderboardEntry extends StatefulWidget {
  final Map<String, dynamic> entry;
  final int index;

  const AnimatedLeaderboardEntry({
    super.key,
    required this.entry,
    required this.index,
  });

  @override
  State<AnimatedLeaderboardEntry> createState() =>
      _AnimatedLeaderboardEntryState();
}

class _AnimatedLeaderboardEntryState extends State<AnimatedLeaderboardEntry>
    with SingleTickerProviderStateMixin {
  int? _previousRank;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _previousRank = widget.index + 1;

    // Initialize pulse animation controller
    _pulseController = AnimationController(
      duration: QuizAnimations.feedback,
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void didUpdateWidget(AnimatedLeaderboardEntry oldWidget) {
    super.didUpdateWidget(oldWidget);

    final currentRank = widget.index + 1;
    final oldRank = oldWidget.index + 1;

    // Detect rank changes
    if (currentRank != oldRank) {
      _previousRank = oldRank;

      // Apply pulse animation when rank improves (moved up = lower rank number)
      if (currentRank < oldRank) {
        _pulseController.forward().then((_) {
          _pulseController.reverse();
        });
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rank = widget.index + 1;
    final username = widget.entry['username'] ?? 'Player $rank';
    final score = widget.entry['score'] ?? 0;

    // Determine rank change indicator
    RankChange rankChange = RankChange.none;
    if (_previousRank != null && _previousRank != rank) {
      if (rank < _previousRank!) {
        rankChange = RankChange.up;
      } else {
        rankChange = RankChange.down;
      }
    }

    // Medal colors and icons for top 3
    Color? medalColor;
    IconData? medalIcon;
    Color? cardGradientStart;
    Color? cardGradientEnd;
    double elevation = 2;

    if (rank == 1) {
      medalColor = QuizColors.gold;
      medalIcon = Icons.emoji_events;
      cardGradientStart = QuizColors.gold.withValues(alpha: 0.3);
      cardGradientEnd = QuizColors.gold.withValues(alpha: 0.1);
      elevation = 6;
    } else if (rank == 2) {
      medalColor = QuizColors.silver;
      medalIcon = Icons.emoji_events;
      cardGradientStart = QuizColors.silver.withValues(alpha: 0.3);
      cardGradientEnd = QuizColors.silver.withValues(alpha: 0.1);
      elevation = 5;
    } else if (rank == 3) {
      medalColor = QuizColors.bronze;
      medalIcon = Icons.emoji_events;
      cardGradientStart = QuizColors.bronze.withValues(alpha: 0.3);
      cardGradientEnd = QuizColors.bronze.withValues(alpha: 0.1);
      elevation = 4;
    }

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: AnimatedContainer(
            duration: QuizAnimations.normal,
            curve: Curves.easeInOut,
            margin: EdgeInsets.only(bottom: QuizSpacing.md),
            child: Card(
              elevation: elevation,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(QuizBorderRadius.md),
                side:
                    medalColor != null
                        ? BorderSide(color: medalColor, width: 1.5)
                        : BorderSide.none,
              ),
              child: Container(
                decoration:
                    rank <= 3 && cardGradientStart != null
                        ? BoxDecoration(
                          gradient: LinearGradient(
                            colors: [cardGradientStart, cardGradientEnd!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(
                            QuizBorderRadius.md,
                          ),
                        )
                        : null,
                child: Padding(
                  padding: EdgeInsets.all(rank <= 3 ? QuizSpacing.md : QuizSpacing.sm),
                  child: Row(
                    children: [
                      // Rank badge/medal
                      _buildRankBadge(rank, medalColor, medalIcon),
                      SizedBox(width: QuizSpacing.md),

                      // Username
                      Expanded(
                        child: Text(
                          username,
                          style: TextStyle(
                            color: QuizColors.textPrimary,
                            fontWeight:
                                rank <= 3 ? FontWeight.bold : FontWeight.normal,
                            fontSize: rank <= 3 ? 16 : 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Rank change indicator
                      if (rankChange != RankChange.none) ...[
                        SizedBox(width: QuizSpacing.sm),
                        _buildRankChangeIndicator(rankChange),
                      ],

                      SizedBox(width: QuizSpacing.md),

                      // Score
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: QuizSpacing.md,
                          vertical: QuizSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color:
                              medalColor?.withValues(alpha: 0.2) ??
                              Theme.of(context).colorScheme.primary.withValues(
                                alpha: 0.2,
                              ),
                          borderRadius: BorderRadius.circular(
                            QuizBorderRadius.circular,
                          ),
                          border: Border.all(
                            color:
                                medalColor ??
                                Theme.of(context).colorScheme.primary,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '$score',
                          style: TextStyle(
                            color:
                                medalColor ??
                                Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: rank <= 3 ? 16 : 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRankBadge(int rank, Color? medalColor, IconData? medalIcon) {
    return Container(
      width: rank <= 3 ? 40 : 32,
      height: rank <= 3 ? 40 : 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
            medalColor?.withValues(alpha: 0.2) ??
            Colors.grey.withValues(alpha: 0.2),
        border: Border.all(
          color: medalColor ?? Colors.grey,
          width: rank <= 3 ? 2 : 1,
        ),
      ),
      child:
          rank <= 3 && medalIcon != null
              ? Icon(
                medalIcon,
                color: medalColor,
                size: 24,
              )
              : Text(
                '$rank',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
    );
  }

  Widget _buildRankChangeIndicator(RankChange change) {
    return Container(
      padding: EdgeInsets.all(QuizSpacing.xs),
      decoration: BoxDecoration(
        color:
            change == RankChange.up
                ? QuizColors.correct.withValues(alpha: 0.2)
                : QuizColors.incorrect.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        change == RankChange.up ? Icons.arrow_upward : Icons.arrow_downward,
        size: 16,
        color: change == RankChange.up ? QuizColors.correct : QuizColors.incorrect,
      ),
    );
  }
}

/// Enum to represent rank change direction
enum RankChange {
  up,
  down,
  none,
}

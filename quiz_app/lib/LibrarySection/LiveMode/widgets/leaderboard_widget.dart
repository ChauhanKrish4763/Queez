import 'package:flutter/material.dart';
import 'package:quiz_app/utils/quiz_design_system.dart';

class LeaderboardWidget extends StatelessWidget {
  final List<Map<String, dynamic>> rankings;
  final String currentUserId;

  const LeaderboardWidget({
    super.key,
    required this.rankings,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(QuizBorderRadius.lg)),
      child: Padding(
        padding: const EdgeInsets.all(QuizSpacing.lg),
        child: Column(
          children: [
            const Text(
              'LEADERBOARD',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: QuizSpacing.md),
            Expanded(
              child: ListView.separated(
                itemCount: rankings.length,
                separatorBuilder: (context, index) => const SizedBox(height: QuizSpacing.sm),
                itemBuilder: (context, index) {
                  final entry = rankings[index];
                  final isCurrentUser = entry['user_id'] == currentUserId;
                  final rank = index + 1;

                  // Medal colors and styles for top 3
                  Color? medalColor;
                  IconData? medalIcon;
                  Color? cardGradientStart;
                  Color? cardGradientEnd;
                  double elevation = 2;

                  if (rank == 1) {
                    medalColor = QuizColors.gold;
                    medalIcon = Icons.emoji_events; // Trophy
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

                  return Card(
                    elevation: isCurrentUser ? elevation + 2 : elevation,
                    color:
                        isCurrentUser
                            ? Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.2)
                            : null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(QuizBorderRadius.md),
                      side:
                          isCurrentUser
                              ? BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2,
                              )
                              : medalColor != null
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
                                borderRadius: BorderRadius.circular(QuizBorderRadius.md),
                              )
                              : null,
                      child: Padding(
                        padding: EdgeInsets.all(rank <= 3 ? QuizSpacing.md : QuizSpacing.sm),
                        child: Row(
                          children: [
                            // Rank badge/medal
                            Container(
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
                            ),
                            const SizedBox(width: QuizSpacing.md),

                            // Username
                            Expanded(
                              child: Text(
                                entry['username'] ?? 'Unknown',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight:
                                      isCurrentUser || rank <= 3
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                  fontSize: rank <= 3 ? 16 : 14,
                                ),
                              ),
                            ),

                            // Score
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: QuizSpacing.md,
                                vertical: QuizSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    medalColor?.withValues(alpha: 0.2) ??
                                    Theme.of(context).colorScheme.primary
                                        .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(QuizBorderRadius.circular),
                                border: Border.all(
                                  color:
                                      medalColor ??
                                      Theme.of(context).colorScheme.primary,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                '${entry['score']}',
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

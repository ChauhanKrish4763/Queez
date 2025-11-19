import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/providers/leaderboard_provider.dart';
import 'package:quiz_app/providers/session_provider.dart';
import 'package:quiz_app/widgets/sci_fi/sci_fi_card.dart';
import 'package:quiz_app/widgets/sci_fi/sci_fi_theme.dart';

class LeaderboardWidget extends ConsumerWidget {
  final int maxEntries;
  final bool showTitle;

  const LeaderboardWidget({
    super.key,
    this.maxEntries = 10,
    this.showTitle = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardState = ref.watch(leaderboardProvider);
    final currentUserId = ref.watch(currentUserProvider);
    final rankings = leaderboardState.rankings.take(maxEntries).toList();

    if (rankings.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showTitle) ...[
          Text(
            'LEADERBOARD',
            style: SciFiTheme.heading2.copyWith(color: SciFiTheme.accent),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
        ],
        ...rankings.map((entry) {
          final isCurrentUser = entry.userId == currentUserId;
          Color rankColor = SciFiTheme.primary;

          if (entry.rank == 1) {
            rankColor = SciFiTheme.warning;
          } else if (entry.rank == 2) {
            rankColor = const Color(0xFFC0C0C0);
          } else if (entry.rank == 3) {
            rankColor = const Color(0xFFCD7F32);
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: SciFiCard(
              glowColor: isCurrentUser ? SciFiTheme.accent : rankColor,
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: rankColor.withValues(alpha: 0.3),
                      border: Border.all(color: rankColor, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        '#${entry.rank}',
                        style: SciFiTheme.body.copyWith(
                          color: rankColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.userId,
                      style: SciFiTheme.body.copyWith(
                        fontWeight:
                            isCurrentUser ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  Text(
                    '${entry.score}',
                    style: SciFiTheme.heading3.copyWith(color: rankColor),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

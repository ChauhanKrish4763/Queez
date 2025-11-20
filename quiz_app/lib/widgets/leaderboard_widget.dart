import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/providers/leaderboard_provider.dart';
import 'package:quiz_app/providers/session_provider.dart';

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
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.secondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
        ],
        ...rankings.map((entry) {
          final isCurrentUser = entry.userId == currentUserId;
          Color rankColor = Theme.of(context).colorScheme.primary;

          if (entry.rank == 1) {
            rankColor = const Color(0xFFFFD700); // Gold
          } else if (entry.rank == 2) {
            rankColor = const Color(0xFFC0C0C0); // Silver
          } else if (entry.rank == 3) {
            rankColor = const Color(0xFFCD7F32); // Bronze
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Card(
              elevation: isCurrentUser ? 4 : 2,
              color:
                  isCurrentUser
                      ? Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.2)
                      : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side:
                    isCurrentUser
                        ? BorderSide(color: rankColor, width: 2)
                        : BorderSide.none,
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
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
                          style: TextStyle(
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
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight:
                              isCurrentUser
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                        ),
                      ),
                    ),
                    Text(
                      '${entry.score}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: rankColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

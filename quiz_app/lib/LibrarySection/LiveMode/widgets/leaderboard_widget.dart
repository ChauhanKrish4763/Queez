import 'package:flutter/material.dart';

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
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
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: rankings.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final entry = rankings[index];
                  final isCurrentUser = entry['user_id'] == currentUserId;
                  final rank = index + 1;

                  Color rankColor = Colors.white;
                  if (rank == 1) {
                    rankColor = const Color(0xFFFFD700); // Gold
                  } else if (rank == 2) {
                    rankColor = const Color(0xFFC0C0C0); // Silver
                  } else if (rank == 3) {
                    rankColor = const Color(0xFFCD7F32); // Bronze
                  }

                  return Card(
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
                              ? BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2,
                              )
                              : BorderSide.none,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: rankColor),
                              color: rankColor.withValues(alpha: 0.2),
                            ),
                            child: Text(
                              '$rank',
                              style: TextStyle(
                                color: rankColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              entry['username'] ?? 'Unknown',
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
                            '${entry['score']}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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

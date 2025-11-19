import 'package:flutter/material.dart';
import 'package:quiz_app/widgets/sci_fi/sci_fi_card.dart';
import 'package:quiz_app/widgets/sci_fi/sci_fi_panel.dart';
import 'package:quiz_app/widgets/sci_fi/sci_fi_theme.dart';

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
    return SciFiPanel(
      child: Column(
        children: [
          Text('LEADERBOARD', style: SciFiTheme.header.copyWith(fontSize: 24)),
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
                  rankColor = const Color(0xFFC0C0C0);
                } // Silver
                else if (rank == 3) {
                  rankColor = const Color(0xFFCD7F32);
                } // Bronze

                return SciFiCard(
                  isSelected: isCurrentUser,
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
                          style: SciFiTheme.body.copyWith(
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
                        style: SciFiTheme.body.copyWith(
                          color: SciFiTheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:quiz_app/LibrarySection/LiveMode/widgets/podium_widget.dart';
import 'package:quiz_app/utils/color.dart';

/// Enhanced host leaderboard panel that displays comprehensive session statistics
/// and participant rankings. This panel is only shown to the quiz host and provides
/// rich visualizations including:
/// - Question progress (e.g., "Question 3/10")
/// - Real-time participant count
/// - Average score across all participants
/// - Full leaderboard with animated rank changes
/// - Answer distribution chart (when available)
///
/// Example usage:
/// ```dart
/// HostLeaderboardPanel(
///   rankings: [
///     {'username': 'Alice', 'score': 2850},
///     {'username': 'Bob', 'score': 2100},
///   ],
///   answerDistribution: {0: 2, 1: 5, 2: 1, 3: 0},
///   questionIndex: 3,
///   totalQuestions: 10,
///   participantCount: 8,
///   averageScore: 1875.5,
/// )
/// ```
class HostLeaderboardPanel extends StatelessWidget {
  /// List of participant rankings with username and score
  final List<Map<String, dynamic>> rankings;

  /// ALL participants from session (including those with 0 points)
  final List<dynamic> allParticipants;

  /// Distribution of answers across options (option index -> count)
  final Map<dynamic, int>? answerDistribution;

  /// Current question number (1-indexed)
  final int questionIndex;

  /// Total number of questions in the quiz
  final int totalQuestions;

  /// Total number of participants in the session
  final int participantCount;

  /// Average score across all participants
  final double averageScore;

  const HostLeaderboardPanel({
    super.key,
    required this.rankings,
    required this.allParticipants,
    this.answerDistribution,
    required this.questionIndex,
    required this.totalQuestions,
    required this.participantCount,
    required this.averageScore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Use the same PodiumWidget as participants see
          if (rankings.length >= 3)
            PodiumWidget(
              topThree: rankings.take(3).toList(),
              currentUserId: '', // Host doesn't need highlighting
            )
          else if (rankings.isNotEmpty)
            _buildSmallLeaderboard(),

          const SizedBox(height: 24),

          // Participant count header
          Row(
            children: [
              const Icon(Icons.people, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                '$participantCount ${participantCount == 1 ? 'participant' : 'participants'}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Participant list with progress
          Expanded(child: _buildParticipantList()),
        ],
      ),
    );
  }

  /// Builds small leaderboard for less than 3 participants
  Widget _buildSmallLeaderboard() {
    return Column(
      children:
          rankings.map((entry) {
            final index = rankings.indexOf(entry);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      entry['username'] ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '${entry['score']}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  /// Builds participant list with their progress - shows ALL participants
  Widget _buildParticipantList() {
    if (allParticipants.isEmpty) {
      return const Center(
        child: Text(
          'No participants yet',
          style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
        ),
      );
    }

    // Create a map of userId -> ranking data for quick lookup
    final rankingMap = <String, Map<String, dynamic>>{};
    for (var ranking in rankings) {
      rankingMap[ranking['user_id']] = ranking;
    }

    return ListView.builder(
      itemCount: allParticipants.length,
      itemBuilder: (context, index) {
        final participant = allParticipants[index];
        final userId = participant.userId;
        final username = participant.username;
        final answersCount = participant.answers.length;
        final currentQuestion = answersCount + 1;

        // Get score from rankings, default to 0
        final score = rankingMap[userId]?['score'] ?? 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Rank or position indicator
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Q$currentQuestion/$totalQuestions',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Score
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '$score',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:quiz_app/LibrarySection/LiveMode/widgets/animated_leaderboard_entry.dart';
import 'package:quiz_app/LibrarySection/LiveMode/widgets/answer_distribution_chart.dart';

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
          // Header with question progress and participant count
          _buildHeader(context),
          const SizedBox(height: 16),

          // Average score display
          _buildAverageScoreCard(context),
          const SizedBox(height: 24),

          // Leaderboard title
          const Text(
            'Leaderboard',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Leaderboard list
          Expanded(
            child: _buildLeaderboardList(),
          ),

          // Answer distribution (if available)
          if (answerDistribution != null) ...[
            const SizedBox(height: 24),
            const Text(
              'Answer Distribution',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            AnswerDistributionChart(distribution: answerDistribution!),
          ],
        ],
      ),
    );
  }

  /// Builds the header section with question progress and participant count
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Question progress
        Text(
          'Question $questionIndex/$totalQuestions',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),

        // Participant count with icon
        Row(
          children: [
            const Icon(
              Icons.people,
              size: 20,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              '$participantCount ${participantCount == 1 ? 'participant' : 'participants'}',
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds the average score card with highlighted styling
  Widget _buildAverageScoreCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.analytics,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 16),
          Text(
            'Average Score: ${averageScore.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the scrollable leaderboard list with animated entries
  Widget _buildLeaderboardList() {
    if (rankings.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No participants yet',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: rankings.length,
      itemBuilder: (context, index) {
        final entry = rankings[index];
        return AnimatedLeaderboardEntry(
          entry: entry,
          index: index,
        );
      },
    );
  }
}

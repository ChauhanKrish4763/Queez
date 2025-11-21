import 'package:flutter/material.dart';
import 'package:quiz_app/utils/quiz_design_system.dart';
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
      padding: EdgeInsets.all(QuizSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(QuizBorderRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with question progress and participant count
          _buildHeader(context),
          SizedBox(height: QuizSpacing.md),

          // Average score display
          _buildAverageScoreCard(context),
          SizedBox(height: QuizSpacing.lg),

          // Leaderboard title
          Text(
            'Leaderboard',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: QuizColors.textPrimary,
            ),
          ),
          SizedBox(height: QuizSpacing.md),

          // Leaderboard list
          Expanded(
            child: _buildLeaderboardList(),
          ),

          // Answer distribution (if available)
          if (answerDistribution != null) ...[
            SizedBox(height: QuizSpacing.lg),
            Text(
              'Answer Distribution',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: QuizColors.textPrimary,
              ),
            ),
            SizedBox(height: QuizSpacing.md),
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
            color: QuizColors.textPrimary,
          ),
        ),

        // Participant count with icon
        Row(
          children: [
            Icon(
              Icons.people,
              size: 20,
              color: QuizColors.info,
            ),
            SizedBox(width: QuizSpacing.sm),
            Text(
              '$participantCount ${participantCount == 1 ? 'participant' : 'participants'}',
              style: TextStyle(
                fontSize: 16,
                color: QuizColors.textSecondary,
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
      padding: EdgeInsets.all(QuizSpacing.md),
      decoration: BoxDecoration(
        color: QuizColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(QuizBorderRadius.sm),
        border: Border.all(
          color: QuizColors.info.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.analytics,
            color: QuizColors.info,
            size: 24,
          ),
          SizedBox(width: QuizSpacing.md),
          Text(
            'Average Score: ${averageScore.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: QuizColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the scrollable leaderboard list with animated entries
  Widget _buildLeaderboardList() {
    if (rankings.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(QuizSpacing.lg),
          child: Text(
            'No participants yet',
            style: TextStyle(
              fontSize: 16,
              color: QuizColors.textSecondary,
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

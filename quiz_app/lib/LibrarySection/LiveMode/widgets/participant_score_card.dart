import 'package:flutter/material.dart';
import 'package:quiz_app/LibrarySection/LiveMode/widgets/animated_score_counter.dart';
import 'package:quiz_app/utils/quiz_design_system.dart';

/// Participant score card widget that displays the participant's current score
/// and feedback on their last answer.
///
/// This widget is shown to participants (not hosts) during live quiz gameplay,
/// providing them with their personal score and immediate feedback without
/// showing the full leaderboard.
///
/// Example usage:
/// ```dart
/// ParticipantScoreCard(
///   currentScore: 1500,
///   pointsEarned: 350,
///   lastAnswerCorrect: true,
/// )
/// ```
class ParticipantScoreCard extends StatelessWidget {
  /// The participant's current total score
  final int currentScore;

  /// Points earned from the last question (optional)
  final int? pointsEarned;

  /// Whether the last answer was correct (null if no answer yet)
  final bool? lastAnswerCorrect;

  const ParticipantScoreCard({
    super.key,
    required this.currentScore,
    this.pointsEarned,
    this.lastAnswerCorrect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(QuizSpacing.md),
      decoration: BoxDecoration(
        color: QuizColors.cardBackground,
        borderRadius: BorderRadius.circular(QuizBorderRadius.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Score display section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Score',
                style: TextStyle(fontSize: 14, color: QuizColors.textSecondary),
              ),
              SizedBox(height: QuizSpacing.xs),
              AnimatedScoreCounter(
                score: currentScore,
                style: QuizTextStyles.scoreText,
              ),
            ],
          ),

          // Correctness icon (only shown if lastAnswerCorrect is not null)
          if (lastAnswerCorrect != null) ...[
            Icon(
              lastAnswerCorrect! ? Icons.check_circle : Icons.cancel,
              size: 48,
              color:
                  lastAnswerCorrect!
                      ? QuizColors.correct
                      : QuizColors.incorrect,
            ),
          ],
        ],
      ),
    );
  }
}

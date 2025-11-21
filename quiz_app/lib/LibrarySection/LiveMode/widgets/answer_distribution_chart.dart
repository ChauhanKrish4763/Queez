import 'package:flutter/material.dart';
import 'package:quiz_app/utils/quiz_design_system.dart';

/// Answer distribution chart widget that displays how participants answered
/// a question with horizontal bars showing the percentage for each option.
/// 
/// This widget is typically shown to the host after all participants have
/// answered, providing insight into how the group performed on the question.
/// 
/// Example usage:
/// ```dart
/// AnswerDistributionChart(
///   distribution: {
///     0: 5,  // 5 participants selected option 0
///     1: 12, // 12 participants selected option 1
///     2: 3,  // 3 participants selected option 2
///     3: 1,  // 1 participant selected option 3
///   },
/// )
/// ```
class AnswerDistributionChart extends StatelessWidget {
  /// Map of option index/value to the number of participants who selected it
  final Map<dynamic, int> distribution;

  const AnswerDistributionChart({
    super.key,
    required this.distribution,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate total responses
    final totalResponses = distribution.values.fold<int>(
      0,
      (sum, count) => sum + count,
    );

    // If no responses, show empty state
    if (totalResponses == 0) {
      return Container(
        padding: EdgeInsets.all(QuizSpacing.lg),
        child: Center(
          child: Text(
            'No responses yet',
            style: TextStyle(
              fontSize: 16,
              color: QuizColors.textSecondary,
            ),
          ),
        ),
      );
    }

    // Get sorted entries for consistent display
    final sortedEntries = distribution.entries.toList()
      ..sort((a, b) => a.key.toString().compareTo(b.key.toString()));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sortedEntries.map((entry) {
        final optionLabel = entry.key;
        final count = entry.value;
        final percentage = (count / totalResponses * 100).round();

        return Padding(
          padding: EdgeInsets.only(bottom: QuizSpacing.md),
          child: _buildDistributionBar(
            context: context,
            optionLabel: optionLabel.toString(),
            count: count,
            percentage: percentage,
            totalResponses: totalResponses,
          ),
        );
      }).toList(),
    );
  }

  /// Builds a single horizontal bar showing the distribution for one option
  Widget _buildDistributionBar({
    required BuildContext context,
    required String optionLabel,
    required int count,
    required int percentage,
    required int totalResponses,
  }) {
    // Generate a color for this option based on its label
    final barColor = _getColorForOption(optionLabel);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Option label and count
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Option $optionLabel',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: QuizColors.textPrimary,
              ),
            ),
            Text(
              '$count ${count == 1 ? 'response' : 'responses'} ($percentage%)',
              style: TextStyle(
                fontSize: 14,
                color: QuizColors.textSecondary,
              ),
            ),
          ],
        ),
        SizedBox(height: QuizSpacing.sm),
        
        // Horizontal bar
        Container(
          height: 32,
          decoration: BoxDecoration(
            color: QuizColors.divider,
            borderRadius: BorderRadius.circular(QuizBorderRadius.sm),
          ),
          child: AnimatedContainer(
            duration: QuizAnimations.slow,
            curve: Curves.easeOut,
            width: MediaQuery.of(context).size.width * (percentage / 100),
            decoration: BoxDecoration(
              color: barColor,
              borderRadius: BorderRadius.circular(QuizBorderRadius.sm),
            ),
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: QuizSpacing.sm),
            child: percentage > 10
                ? Text(
                    '$percentage%',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }

  /// Returns a color for the given option label
  /// Uses a predefined set of colors to ensure visual distinction
  Color _getColorForOption(String optionLabel) {
    // Parse the option label to get an index
    final index = int.tryParse(optionLabel) ?? optionLabel.hashCode;
    
    // Predefined color palette for options
    final colors = [
      QuizColors.info,      // Blue
      QuizColors.correct,   // Green
      QuizColors.warning,   // Orange
      const Color(0xFF9C27B0), // Purple
      const Color(0xFFE91E63), // Pink
      const Color(0xFF00BCD4), // Cyan
      const Color(0xFF8BC34A), // Light Green
      const Color(0xFFFF5722), // Deep Orange
    ];

    return colors[index % colors.length];
  }
}

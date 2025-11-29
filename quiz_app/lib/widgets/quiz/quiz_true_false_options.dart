import 'package:flutter/material.dart';
import 'package:quiz_app/widgets/quiz/quiz_option_card.dart';

/// A reusable True/False options widget for quiz questions.
/// Used by both single player and multiplayer modes.
class QuizTrueFalseOptions extends StatelessWidget {
  final int? userAnswer; // 0 = True, 1 = False
  final int? correctAnswer; // 0 = True, 1 = False
  final ValueChanged<int> onAnswerSelected;
  final bool hasAnswered;
  final bool enabled;

  const QuizTrueFalseOptions({
    super.key,
    required this.userAnswer,
    required this.onAnswerSelected,
    this.correctAnswer,
    this.hasAnswered = false,
    this.enabled = true,
  });

  QuizOptionState _getOptionState(int index) {
    final bool isSelected = userAnswer == index;
    final bool isCorrectOption = index == correctAnswer;

    // Show instant feedback when user has answered AND we know the correct answer
    if (userAnswer != null && correctAnswer != null) {
      if (isCorrectOption) return QuizOptionState.correct;
      if (isSelected && !isCorrectOption) return QuizOptionState.incorrect;
      return QuizOptionState.neutral;
    }

    // Before answering or without correct answer info, just show selection state
    if (isSelected) return QuizOptionState.selected;
    return QuizOptionState.neutral;
  }

  void _handleTap(int index) {
    if (!enabled || hasAnswered) return;
    if (userAnswer != null) return; // Already answered
    onAnswerSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        QuizOptionCard(
          text: 'TRUE',
          state: _getOptionState(0),
          onTap: () => _handleTap(0),
          enabled: enabled && !hasAnswered && userAnswer == null,
        ),
        const SizedBox(height: 12),
        QuizOptionCard(
          text: 'FALSE',
          state: _getOptionState(1),
          onTap: () => _handleTap(1),
          enabled: enabled && !hasAnswered && userAnswer == null,
        ),
      ],
    );
  }
}

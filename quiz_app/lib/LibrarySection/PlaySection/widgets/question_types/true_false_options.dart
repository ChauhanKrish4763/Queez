import 'package:flutter/material.dart';
import 'package:quiz_app/CreateSection/models/question.dart';
import 'package:quiz_app/widgets/quiz/quiz_widgets.dart';

/// True/False options widget for single player mode.
/// Uses the shared QuizTrueFalseOptions component.
class TrueFalseOptions extends StatelessWidget {
  final Question question;
  final int? userAnswer;
  final ValueChanged<int> onAnswerSelected;

  const TrueFalseOptions({
    super.key,
    required this.question,
    required this.userAnswer,
    required this.onAnswerSelected,
  });

  @override
  Widget build(BuildContext context) {
    return QuizTrueFalseOptions(
      userAnswer: userAnswer,
      correctAnswer: userAnswer != null ? question.correctAnswerIndex : null,
      onAnswerSelected: onAnswerSelected,
      hasAnswered: userAnswer != null,
    );
  }
}

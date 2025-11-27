import 'package:flutter/material.dart';
import 'package:quiz_app/CreateSection/models/question.dart';
import 'package:quiz_app/widgets/quiz/quiz_widgets.dart';

/// MCQ options widget for single player mode.
/// Uses the shared QuizMcqOptions component.
class McqOptions extends StatelessWidget {
  final Question question;
  final dynamic userAnswer;
  final ValueChanged<dynamic> onAnswerSelected;
  final bool isMultiSelect;

  const McqOptions({
    super.key,
    required this.question,
    required this.userAnswer,
    required this.onAnswerSelected,
    this.isMultiSelect = false,
  });

  @override
  Widget build(BuildContext context) {
    // Only pass correct answer after user has answered (for instant feedback)
    final bool hasUserAnswered = userAnswer != null;
    
    return QuizMcqOptions(
      options: question.options,
      userAnswer: userAnswer,
      onAnswerSelected: (answer) {
        // Prevent changing answer after selection (single select only)
        if (!isMultiSelect && userAnswer != null) return;
        onAnswerSelected(answer);
      },
      isMultiSelect: isMultiSelect,
      // Pass correct answer only after user answers for instant feedback
      correctAnswerIndex: hasUserAnswered && !isMultiSelect ? question.correctAnswerIndex : null,
      correctAnswerIndices: hasUserAnswered && isMultiSelect ? question.correctAnswerIndices : null,
      hasAnswered: hasUserAnswered,
    );
  }
}

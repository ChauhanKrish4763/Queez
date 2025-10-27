import 'package:quiz_app/CreateSection/models/question.dart';

class QuizAttempt {
  final List<Question> questions;
  final List<dynamic> answers;
  int score = 0;

  QuizAttempt({required this.questions})
    : answers = List<dynamic>.filled(questions.length, null);

  void recordAnswer(int questionIndex, dynamic answer) {
    if (questionIndex >= 0 && questionIndex < answers.length) {
      answers[questionIndex] = answer;
    }
  }

  void calculateScore() {
    score = 0;
    for (int i = 0; i < questions.length; i++) {
      final question = questions[i];
      final userAnswer = answers[i];

      if (userAnswer == null) continue;

      bool isCorrect = false;
      if (question.type == 'multiMcq') {
        // For multi-select, compare sorted lists
        List<int> userSelection = List<int>.from(userAnswer)..sort();
        List<int> correctSelection = List<int>.from(
          question.correctAnswerIndices!,
        )..sort();
        isCorrect =
            userSelection.length == correctSelection.length &&
            userSelection.asMap().entries.every(
              (entry) => entry.value == correctSelection[entry.key],
            );
      } else {
        // For other types, direct comparison
        isCorrect = userAnswer == question.correctAnswerIndex;
      }

      if (isCorrect) {
        score++;
      }
    }
  }
}

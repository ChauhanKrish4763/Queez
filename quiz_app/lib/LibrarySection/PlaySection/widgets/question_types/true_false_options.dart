import 'package:flutter/material.dart';
import 'package:quiz_app/CreateSection/models/question.dart';
import 'package:quiz_app/LibrarySection/PlaySection/widgets/option_card.dart';

class TrueFalseOptions extends StatelessWidget {
  final Question question;
  final int? userAnswer;
  final ValueChanged<int> onAnswerSelected;

  const TrueFalseOptions({
    Key? key,
    required this.question,
    required this.userAnswer,
    required this.onAnswerSelected,
  }) : super(key: key);

  OptionState _getOptionState(int index) {
    if (userAnswer != null) {
      // Answered
      bool isCorrect = index == question.correctAnswerIndex;
      if (isCorrect) return OptionState.correct;
      if (userAnswer == index && !isCorrect) return OptionState.incorrect;
    }
    if (userAnswer == index) return OptionState.selected;
    return OptionState.neutral;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(question.options.length, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: OptionCard(
            text: question.options[index],
            state: _getOptionState(index),
            onTap: () => onAnswerSelected(index),
          ),
        );
      }),
    );
  }
}

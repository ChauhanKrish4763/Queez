import 'package:flutter/material.dart';
import 'package:quiz_app/CreateSection/models/question.dart';
import 'package:quiz_app/LibrarySection/LiveMode/widgets/drag_drop_interface.dart';
import 'package:quiz_app/LibrarySection/LiveMode/widgets/multiple_choice_options.dart';
import 'package:quiz_app/LibrarySection/LiveMode/widgets/true_false_options.dart';

/// Utility class for handling different question types in live multiplayer quiz
/// Routes to appropriate UI component based on question type
class QuestionTypeHandler {
  /// Builds the appropriate question UI based on the question type
  ///
  /// Parameters:
  /// - [question]: The question data containing type and options
  /// - [onAnswerSelected]: Callback when user selects/submits an answer (receives index as int)
  /// - [hasAnswered]: Whether the user has already answered this question
  /// - [selectedAnswer]: The answer index the user selected (if any)
  /// - [isCorrect]: Whether the selected answer was correct (null if not yet revealed)
  /// - [correctAnswer]: The correct answer index (for display after submission)
  ///
  /// Returns the appropriate widget for the question type
  static Widget buildQuestionUI({
    required Map<String, dynamic> question,
    required Function(dynamic) onAnswerSelected,
    required bool hasAnswered,
    dynamic selectedAnswer,
    bool? isCorrect,
    dynamic correctAnswer,
  }) {
    // Extract question type from the question data
    final String? typeString = question['type'] as String?;
    final QuestionType questionType = _parseQuestionType(typeString);

    // Extract options from question data
    final List<String> options = List<String>.from(question['options'] ?? []);

    // Convert correctAnswer to string for display
    final String? correctAnswerStr = correctAnswer?.toString();

    // Route to appropriate UI component based on question type
    switch (questionType) {
      case QuestionType.singleMcq:
      case QuestionType.multiMcq:
        // Multiple choice questions - render all options as buttons
        return MultipleChoiceOptions(
          options: options,
          onSelect: (index) => onAnswerSelected(index),
          selectedAnswer: selectedAnswer as int?,
          correctAnswer: correctAnswerStr,
          hasAnswered: hasAnswered,
          isCorrect: isCorrect,
        );

      case QuestionType.trueFalse:
        // True/False questions - render exactly two buttons
        return TrueFalseOptions(
          onSelect: (index) => onAnswerSelected(index),
          selectedAnswer: selectedAnswer as int?,
          correctAnswer: int.tryParse(correctAnswerStr ?? ''),
          hasAnswered: hasAnswered,
          isCorrect: isCorrect,
        );

      case QuestionType.dragAndDrop:
        // Drag and drop questions - render draggable items and drop zones
        final List<String> items = List<String>.from(
          question['dragItems'] ?? options,
        );
        final List<String>? dropTargets = question['dropTargets'] != null
            ? List<String>.from(question['dropTargets'])
            : null;
        return DragDropInterface(
          items: items,
          dropTargets: dropTargets,
          onOrderSubmit: (matches) => onAnswerSelected(matches),
          hasAnswered: hasAnswered,
          isCorrect: isCorrect,
        );
    }
  }

  /// Parses a question type string into a QuestionType enum
  /// Returns singleMcq as default if type is null or unrecognized
  static QuestionType _parseQuestionType(String? typeString) {
    if (typeString == null) return QuestionType.singleMcq;

    switch (typeString.toLowerCase()) {
      case 'singlemcq':
      case 'single_mcq':
      case 'single':
        return QuestionType.singleMcq;

      case 'multimcq':
      case 'multi_mcq':
      case 'multiple':
        return QuestionType.multiMcq;

      case 'truefalse':
      case 'true_false':
      case 'true/false':
      case 'tf':
        return QuestionType.trueFalse;

      case 'draganddrop':
      case 'drag_and_drop':
      case 'drag&drop':
      case 'dragdrop':
        return QuestionType.dragAndDrop;

      default:
        // Default to single MCQ for unrecognized types
        return QuestionType.singleMcq;
    }
  }
}

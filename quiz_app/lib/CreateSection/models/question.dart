enum QuestionType {
  singleMcq, // Single choice MCQ (your current mcq)
  multiMcq, // Multiple choice MCQ
  trueFalse, // True/False questions
  dragAndDrop, // Drag and drop questions
}

class Question {
  String id;
  String questionText;
  QuestionType type;
  List<String> options;
  int? correctAnswerIndex; // For single MCQ and True/False
  List<int>? correctAnswerIndices; // For multi MCQ
  List<String>? dragItems; // For drag and drop source items
  List<String>? dropTargets; // For drag and drop target areas
  Map<String, String>? correctMatches; // For drag and drop correct pairs

  Question({
    required this.id,
    this.questionText = '',
    this.type = QuestionType.singleMcq,
    List<String>? options,
    this.correctAnswerIndex,
    this.correctAnswerIndices,
    this.dragItems,
    this.dropTargets,
    this.correctMatches,
  }) : options = options ?? _getDefaultOptions(type);

  static List<String> _getDefaultOptions(QuestionType type) {
    switch (type) {
      case QuestionType.trueFalse:
        return ['True', 'False'];
      case QuestionType.dragAndDrop:
        return []; // No traditional options for drag and drop
      default:
        return ['', '', '', ''];
    }
  }

  bool get isComplete {
    if (questionText.isEmpty) return false;

    switch (type) {
      case QuestionType.singleMcq:
      case QuestionType.trueFalse:
        return correctAnswerIndex != null &&
            options.every((option) => option.isNotEmpty);

      case QuestionType.multiMcq:
        return correctAnswerIndices != null &&
            correctAnswerIndices!.isNotEmpty &&
            options.every((option) => option.isNotEmpty);

      case QuestionType.dragAndDrop:
        return dragItems != null &&
            dropTargets != null &&
            correctMatches != null &&
            dragItems!.isNotEmpty &&
            dropTargets!.isNotEmpty &&
            correctMatches!.isNotEmpty;
    }
  }

  String get typeString {
    switch (type) {
      case QuestionType.singleMcq:
        return 'Single Choice';
      case QuestionType.multiMcq:
        return 'Multiple Choice';
      case QuestionType.trueFalse:
        return 'True/False';
      case QuestionType.dragAndDrop:
        return 'Drag & Drop';
    }
  }

  static QuestionType typeFromString(String typeString) {
    switch (typeString) {
      case 'Single Choice':
        return QuestionType.singleMcq;
      case 'Multiple Choice':
        return QuestionType.multiMcq;
      case 'True/False':
        return QuestionType.trueFalse;
      case 'Drag & Drop':
        return QuestionType.dragAndDrop;
      default:
        return QuestionType.singleMcq;
    }
  }

  // Add these methods to your existing Question class in question.dart

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionText': questionText,
      'type': type.toString().split('.').last,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'correctAnswerIndices': correctAnswerIndices,
      'dragItems': dragItems,
      'dropTargets': dropTargets,
      'correctMatches': correctMatches,
    };
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      questionText: json['questionText'] ?? '',
      type: _typeFromString(json['type'] ?? 'singleMcq'),
      options: List<String>.from(json['options'] ?? []),
      correctAnswerIndex: json['correctAnswerIndex'],
      correctAnswerIndices:
          json['correctAnswerIndices'] != null
              ? List<int>.from(json['correctAnswerIndices'])
              : null,
      dragItems:
          json['dragItems'] != null
              ? List<String>.from(json['dragItems'])
              : null,
      dropTargets:
          json['dropTargets'] != null
              ? List<String>.from(json['dropTargets'])
              : null,
      correctMatches:
          json['correctMatches'] != null
              ? Map<String, String>.from(json['correctMatches'])
              : null,
    );
  }

  static QuestionType _typeFromString(String typeString) {
    switch (typeString) {
      case 'singleMcq':
        return QuestionType.singleMcq;
      case 'multiMcq':
        return QuestionType.multiMcq;
      case 'trueFalse':
        return QuestionType.trueFalse;
      case 'dragAndDrop':
        return QuestionType.dragAndDrop;
      default:
        return QuestionType.singleMcq;
    }
  }
}

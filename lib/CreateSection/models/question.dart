enum QuestionType { mcq, trueFalse }

class Question {
  String id;
  String questionText;
  QuestionType type;
  List<String> options;
  int? correctAnswerIndex;

  Question({
    required this.id,
    this.questionText = '',
    this.type = QuestionType.mcq,
    List<String>? options,
    this.correctAnswerIndex,
  }) : options = options ?? (type == QuestionType.trueFalse ? ['True', 'False'] : ['', '', '', '']);

  bool get isComplete => 
      questionText.isNotEmpty && 
      correctAnswerIndex != null && 
      options.every((option) => option.isNotEmpty);

  // Helper method to get string representation of question type
  String get typeString => type == QuestionType.mcq ? 'Multiple Choice' : 'True/False';
  
  // Helper method to set type from string
  static QuestionType typeFromString(String typeString) {
    return typeString == 'Multiple Choice' ? QuestionType.mcq : QuestionType.trueFalse;
  }
}

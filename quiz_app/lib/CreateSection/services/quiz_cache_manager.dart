// lib/services/quiz_cache_manager.dart
import '../models/quiz.dart';
import '../models/question.dart';

class QuizCacheManager {
  static QuizCacheManager? _instance;
  static QuizCacheManager get instance => _instance ??= QuizCacheManager._();

  QuizCacheManager._();

  Quiz? _currentQuiz;

  void cacheQuizDetails({
    required String title,
    required String description,
    required String language,
    required String category,
    required String creatorId,
    String? coverImagePath,
  }) {
    _currentQuiz = Quiz(
      title: title,
      description: description,
      language: language,
      category: category,
      coverImagePath: coverImagePath,
      creatorId: creatorId,
      createdAt: DateTime.now(), // Add this line
      questions: [], // Initialize with empty list
    );
  }

  void updateQuestions(List<Question> questions) {
    if (_currentQuiz != null) {
      _currentQuiz!.questions = questions;
    }
  }

  Quiz? get currentQuiz => _currentQuiz;

  void clearCache() {
    _currentQuiz = null;
  }

  bool get hasQuizDetails => _currentQuiz != null;
}

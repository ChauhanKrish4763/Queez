class LibraryItem {
  final String id;
  final String type; // "quiz" or "flashcard"
  final String title;
  final String description;
  final String? coverImagePath;
  final String? createdAt;
  final int itemCount; // questionCount for quizzes, cardCount for flashcards
  final String category;
  final String language; // Only for quizzes
  final String? originalOwner;
  final String? originalOwnerUsername;
  final String? sharedMode; // Only for quizzes

  LibraryItem({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    this.coverImagePath,
    this.createdAt,
    required this.itemCount,
    required this.category,
    this.language = '',
    this.originalOwner,
    this.originalOwnerUsername,
    this.sharedMode,
  });

  factory LibraryItem.fromJson(Map<String, dynamic> json) {
    return LibraryItem(
      id: json['id'],
      type: json['type'],
      title: json['title'],
      description: json['description'] ?? '',
      coverImagePath: json['coverImagePath'],
      createdAt: json['createdAt'],
      itemCount: json['itemCount'] ?? 0,
      category: json['category'] ?? '',
      language: json['language'] ?? '',
      originalOwner: json['originalOwner'],
      originalOwnerUsername: json['originalOwnerUsername'],
      sharedMode: json['sharedMode'],
    );
  }

  bool get isQuiz => type == 'quiz';
  bool get isFlashcard => type == 'flashcard';
  bool get isNote => type == 'note';

  // Convert to QuizLibraryItem (for quizzes only)
  dynamic toQuizLibraryItem() {
    // Import QuizLibraryItem at the call site
    return {
      'id': id,
      'title': title,
      'description': description,
      'coverImagePath': coverImagePath,
      'createdAt': createdAt,
      'questionCount': itemCount,
      'language': language,
      'category': category,
      'originalOwner': originalOwner,
      'originalOwnerUsername': originalOwnerUsername,
      'sharedMode': sharedMode,
    };
  }
}

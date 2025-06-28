
class QuizLibraryItem {
  final String id;
  final String title;
  final String description;
  final String? coverImagePath;
  final String? createdAt;
  final int questionCount;
  final String language;
  final String category;

  QuizLibraryItem({
    required this.id,
    required this.title,
    required this.description,
    this.coverImagePath,
    this.createdAt,
    required this.questionCount,
    required this.language,
    required this.category,
  });

  factory QuizLibraryItem.fromJson(Map<String, dynamic> json) {
    return QuizLibraryItem(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      coverImagePath: json['coverImagePath'],
      createdAt: json['createdAt'],
      questionCount: json['questionCount'] ?? 0,
      language: json['language'] ?? '',
      category: json['category'] ?? '',
    );
  }
}

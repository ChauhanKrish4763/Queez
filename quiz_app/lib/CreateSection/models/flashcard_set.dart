class Flashcard {
  String? id;
  String front; // Question/Term
  String back; // Answer/Definition

  Flashcard({this.id, required this.front, required this.back});

  Map<String, dynamic> toJson() {
    return {'id': id, 'front': front, 'back': back};
  }

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(id: json['id'], front: json['front'], back: json['back']);
  }
}

class FlashcardSet {
  String? id;
  String title;
  String description;
  String category;
  String? coverImagePath;
  String creatorId;
  List<Flashcard> cards;
  String? createdAt;

  FlashcardSet({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    this.coverImagePath,
    required this.creatorId,
    List<Flashcard>? cards,
    this.createdAt,
  }) : cards = cards ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'coverImagePath': coverImagePath,
      'creatorId': creatorId,
      'cards': cards.map((c) => c.toJson()).toList(),
      'createdAt': createdAt,
    };
  }

  factory FlashcardSet.fromJson(Map<String, dynamic> json) {
    return FlashcardSet(
      id: json['id'] ?? json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      coverImagePath: json['coverImagePath'],
      creatorId: json['creatorId'] ?? json['creator_id'] ?? '',
      cards:
          (json['cards'] as List? ?? [])
              .map((c) => Flashcard.fromJson(c))
              .toList(),
      createdAt: json['createdAt'] ?? '',
    );
  }
}

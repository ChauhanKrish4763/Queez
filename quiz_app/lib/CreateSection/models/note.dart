class Note {
  String? id;
  String title;
  String description;
  String category;
  String? coverImagePath;
  String creatorId;
  String content; // Quill Delta JSON as string
  String? createdAt;
  String? updatedAt;

  Note({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    this.coverImagePath,
    required this.creatorId,
    required this.content,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'coverImagePath': coverImagePath,
      'creatorId': creatorId,
      'content': content,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] ?? json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      coverImagePath: json['coverImagePath'],
      creatorId: json['creatorId'] ?? json['creator_id'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

class NoteLibraryItem {
  String id;
  String title;
  String description;
  String category;
  String? coverImagePath;
  String? createdAt;
  String? updatedAt;

  NoteLibraryItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.coverImagePath,
    this.createdAt,
    this.updatedAt,
  });

  factory NoteLibraryItem.fromJson(Map<String, dynamic> json) {
    return NoteLibraryItem(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      coverImagePath: json['coverImagePath'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}

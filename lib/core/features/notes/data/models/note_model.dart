import '../../domain/entities/note.dart';

class NoteModel extends Note {
  NoteModel({
    required super.id,
    required super.title,
    required super.content,
    super.isPinned = false,
    super.category = NoteCategory.personal,
    super.colorValue = 0xFFFFFFFF,
    required super.createdAt,
    required super.lastEdited,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'isPinned': isPinned,
      'category': category.name,
      'colorValue': colorValue,
      'createdAt': createdAt.toIso8601String(),
      'lastEdited': lastEdited.toIso8601String(),
    };
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      isPinned: map['isPinned'] as bool? ?? false,
      category: NoteCategory.values.byName(map['category'] ?? 'personal'),
      colorValue: map['colorValue'] as int? ?? 0xFFFFFFFF,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      lastEdited: map['lastEdited'] != null
          ? DateTime.parse(map['lastEdited'] as String)
          : DateTime.now(),
    );
  }
}

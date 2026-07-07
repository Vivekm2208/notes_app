import '../../domain/entities/note.dart';

class NoteModel extends Note {
  NoteModel({
    required super.id,
    required super.title,
    required super.content,
    super.isPinned = false,
    super.category = NoteCategory.personal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'isPinned': isPinned,
      'category': category.name,
    };
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      isPinned: map['isPinned'] ?? false,
      category: NoteCategory.values.byName(map['category'] ?? 'personal'),
    );
  }
}

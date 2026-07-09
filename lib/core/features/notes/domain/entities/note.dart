enum NoteCategory { personal, study, work, ideas }

class Note {
  final String id;
  final String title;
  final String content;
  final NoteCategory category;
  final int colorValue;
  final DateTime createdAt;
  final DateTime lastEdited;
  final bool isPinned;

  const Note({
    required this.title,
    required this.id,
    required this.content,
    this.category = NoteCategory.personal,
    this.colorValue = 0xFFFFFFFF,
    required this.createdAt,
    required this.lastEdited,
    this.isPinned = false,
  });

  Note copyWith({
    String? id,
    String? title,
    String? content,
    bool? isPinned,
    int? colorValue,
    NoteCategory? category,
    DateTime? createdAt,
    DateTime? lastEdited,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      isPinned: isPinned ?? this.isPinned,
      colorValue: colorValue ?? this.colorValue,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      lastEdited: lastEdited ?? this.lastEdited,
    );
  }
}

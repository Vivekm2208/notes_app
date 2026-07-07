enum NoteCategory { personal, study, work, ideas }

class Note {
  final String id;
  final String title;
  final String content;
  final bool isPinned;
  final NoteCategory category;

  const Note({
    required this.title,
    required this.id,
    required this.content,
    this.isPinned = false,
    this.category = NoteCategory.personal,
  });

  Note copyWith({
    String? id,
    String? title,
    String? content,
    bool? isPinned,
    NoteCategory? category,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      isPinned: isPinned ?? this.isPinned,
      category: category ?? this.category,
    );
  }
}

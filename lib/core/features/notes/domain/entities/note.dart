class Note {
  final String id;
  final String title;
  final String content;
  final bool isPinned;

  const Note({
    required this.title,
    required this.id,
    required this.content,
    this.isPinned = false,
  });
}

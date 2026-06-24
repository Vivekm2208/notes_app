import '../../domain/entities/note.dart';

class NoteModel extends Note {
  const NoteModel({
    required super.id,
    required super.title,
    required super.content,
  });

  factory NoteModel.fromJSON(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'],
      title: json['title'],
      content: json['content'],
    );
  }
  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'content': content};
  }
}

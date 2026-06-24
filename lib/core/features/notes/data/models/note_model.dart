import '../../domain/entities/note.dart';

class NoteModel extends Note {
  NoteModel({required super.id, required super.title, required super.content});

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title, 'content': content};
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'],
      title: map['title'],
      content: map['content'],
    );
  }
}

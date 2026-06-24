import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repositories.dart';

import '../datasources/local_note_datasources.dart';
import '../models/note_model.dart';

class NoteRepositoryImpl implements NoteRepositories {
  final LocalNoteDatasources datasource;
  NoteRepositoryImpl(this.datasource);

  @override
  Future<void> addNote(Note note) async {
    final model = NoteModel(
      id: note.id,
      title: note.title,
      content: note.content,
    );

    await datasource.addNote(model);
  }

  @override
  Future<List<Note>> getNotes() async {
    return datasource.getNotes();
  }

  @override
  Future<void> deleteNote(String id) async {
    await datasource.deleteNote(id);
  }

  @override
  Future<void> updateNote(Note note) async {
    final model = NoteModel(
      id: note.id,
      title: note.title,
      content: note.content,
    );
    await datasource.updateNote(model);
  }
}

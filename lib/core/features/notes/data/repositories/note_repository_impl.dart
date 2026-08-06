import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repositories.dart';

import '../datasources/local_note_datasources.dart';
import '../models/note_model.dart';

class NoteRepositoryImpl implements NoteRepositories {
  NoteRepositoryImpl(this.datasource);

  final LocalNoteDatasources datasource;

  @override
  Future<void> addNote(Note note) async {
    await datasource.addNote(NoteModel.fromEntity(note));
  }

  @override
  Future<void> deleteNote(String id) async {
    await datasource.deleteNote(id);
  }

  @override
  Future<List<Note>> getNotes() async {
    return datasource.getNotes();
  }

  @override
  Future<void> updateNote(Note note) async {
    await datasource.updateNote(NoteModel.fromEntity(note));
  }
}

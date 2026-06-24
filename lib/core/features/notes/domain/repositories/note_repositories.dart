import '../entities/note.dart';

abstract class NoteRepositories {
  Future<void> addNote(Note note);
  Future<List<Note>> getNotes();

  Future<void> deleteNote(String id);

  Future<void> updateNote(Note note);
}

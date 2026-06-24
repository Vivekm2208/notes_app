import '../models/note_model.dart';

class LocalNoteDatasources {
  final List<NoteModel> _notes = [];

  Future<void> addNote(NoteModel note) async {
    _notes.add(note);
  }

  Future<List<NoteModel>> getNotes() async {
    return _notes;
  }

  Future<void> deleteNote(String id) async {
    _notes.removeWhere((note) => note.id == id);
  }

  Future<void> updateNote(NoteModel updatedNote) async {
    final index = _notes.indexWhere((note) => note.id == updatedNote.id);

    if (index != -1) {
      _notes[index] = updatedNote;
    }
  }
}

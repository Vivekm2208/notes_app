import 'package:hive/hive.dart';

import '../models/note_model.dart';

class LocalNoteDatasources {
  late Box notesBox;

  Future<void> init() async {
    notesBox = await Hive.openBox('notes');
  }

  Future<void> addNote(NoteModel note) async {
    await notesBox.put(note.id, note.toMap());
  }

  Future<List<NoteModel>> getNotes() async {
    return notesBox.values
        .map((note) => NoteModel.fromMap(Map<String, dynamic>.from(note)))
        .toList();
  }

  Future<void> deleteNote(String id) async {
    await notesBox.delete(id);
  }

  Future<void> updateNote(NoteModel updatedNote) async {
    await notesBox.put(updatedNote.id, updatedNote.toMap());
  }
}

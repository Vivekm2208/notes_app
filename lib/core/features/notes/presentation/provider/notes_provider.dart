import 'package:flutter/material.dart';
import 'package:notes_app/core/features/notes/domain/repositories/note_repositories.dart';
import 'package:notes_app/core/features/notes/domain/entities/note.dart';

class NotesProvider extends ChangeNotifier {
  NotesProvider({required this.repositories});

  final NoteRepositories repositories;

  List<Note> _notes = [];

  List<Note> get notes => _notes;

  Future<void> loadNotes() async {
    _notes = await repositories.getNotes();

    notifyListeners();
  }

  Future<void> addNote(Note note) async {
    await repositories.addNote(note);

    await loadNotes();
  }

  Future<void> deleteNote(String id) async {
    await repositories.deleteNote(id);

    await loadNotes();
  }

  Future<void> updateNote(Note note) async {
    await repositories.updateNote(note);
    await loadNotes();
  }
}

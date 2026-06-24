import 'package:flutter/material.dart';
import 'package:notes_app/core/features/notes/domain/repositories/note_repositories.dart';
import 'package:notes_app/core/features/notes/domain/entities/note.dart';

class NotesProvider extends ChangeNotifier {
  NotesProvider({required this.repositories});

  final NoteRepositories repositories;

  List<Note> _notes = [];

  List<Note> get notes => _notes;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();

    _notes = await repositories.getNotes();
    _isLoading = false;
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

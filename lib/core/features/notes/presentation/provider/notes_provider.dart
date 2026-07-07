import 'package:flutter/material.dart';
import 'package:notes_app/core/features/notes/domain/repositories/note_repositories.dart';
import 'package:notes_app/core/features/notes/domain/entities/note.dart';

class NotesProvider extends ChangeNotifier {
  NotesProvider({required this.repositories});

  final NoteRepositories repositories;

  NoteCategory? _selectedCategory;

  NoteCategory? get selectedCategory => _selectedCategory;

  List<Note> _notes = [];

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  List<Note> get notes => _notes;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  List<Note> get filteredNotes {
    List<Note> filtered = _notes;

    if (_selectedCategory != null) {
      filtered = filtered
          .where((note) => note.category == _selectedCategory)
          .toList();
    }
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((note) {
        return note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            note.content.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
    return filtered;
  }

  void updateSearchQuery(String value) async {
    _searchQuery = value;
    notifyListeners();
  }

  void updateSelectedCategory(NoteCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();

    _notes = await repositories.getNotes();

    _notes.sort((a, b) {
      if (a.isPinned != b.isPinned) {
        return a.isPinned ? -1 : 1;
      }

      return a.title.compareTo(b.title);
    });
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

  Future<void> togglePin(Note note) async {
    final updatedNote = Note(
      id: note.id,
      title: note.title,
      content: note.content,
      isPinned: !note.isPinned,
    );

    await updateNote(updatedNote);
  }
}

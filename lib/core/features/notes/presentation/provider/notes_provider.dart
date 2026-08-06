import 'package:flutter/material.dart';
import 'package:notes_app/core/features/notes/domain/entities/checklist_item.dart';
import 'package:notes_app/core/features/notes/domain/repositories/note_repositories.dart';
import 'package:notes_app/core/features/notes/domain/entities/note.dart';
import 'package:notes_app/core/services/notification_service.dart';

class NotesProvider extends ChangeNotifier {
  NotesProvider({required this.repositories});

  final NoteRepositories repositories;

  bool _isLoading = false;
  List<Note> _notes = [];
  String _searchQuery = '';
  NoteCategory? _selectedCategory;
  SortType _sortType = SortType.recent;

  NoteCategory? get selectedCategory => _selectedCategory;

  String get searchQuery => _searchQuery;

  List<Note> get notes => _notes;

  bool get isLoading => _isLoading;

  SortType get sortType => _sortType;

  List<Note> get activeNotes => _filterNotes(NoteStatus.active);

  List<Note> get archivedNotes => _filterNotes(NoteStatus.archived);

  List<Note> get trashedNotes => _filterNotes(NoteStatus.trashed);

  void updateSearchQuery(String value) async {
    _searchQuery = value;
    notifyListeners();
  }

  void updateSelectedCategory(NoteCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void updateSortType(SortType value) {
    _sortType = value;
    _sortNotes();
    notifyListeners();
  }

  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();

    _notes = await repositories.getNotes();

    _sortNotes();

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
    final updatedNote = note.copyWith(isPinned: !note.isPinned);

    await updateNote(updatedNote);
  }

  Future<void> deleteForever(String id) async {
    await deleteNote(id);
  }

  Future<void> archiveNote(Note note) async {
    final archiveNote = note.copyWith(status: NoteStatus.archived);

    await updateNote(archiveNote);
  }

  Future<void> moveToTrash(Note note) async {
    if (note.notificationId != null) {
      await NotificationService.instance.cancelNotification(
        note.notificationId!,
      );
    }

    final trashedNote = note.copyWith(
      status: NoteStatus.trashed,
      reminderAt: null,
      notificationId: null,
    );

    await updateNote(trashedNote);
  }

  Future<void> restoreNote(Note note) async {
    final restoreNote = note.copyWith(status: NoteStatus.active);

    await updateNote(restoreNote);
  }

  Future<void> toggleCheckListItem(Note note, String itemId) async {
    final updatedItems = note.checklistItems.map((item) {
      if (item.id == item.id) {
        return item.copyWith(isCompleted: item.isCompleted);
      }
      return item;
    }).toList();
    final updatedNote = note.copyWith(checklistItems: updatedItems);

    await updateNote(updatedNote);
  }

  Future<void> addCheckListItem(Note note, ChecklistItem item) async {
    final updatedItem = [...note.checklistItems, item];

    final updatedNote = note.copyWith(checklistItems: updatedItem);

    await updateNote(updatedNote);
  }

  Future<void> updateChecklistItem(Note note, ChecklistItem updatedItem) async {
    final updatedItems = note.checklistItems.map((currentItem) {
      if (currentItem.id == updatedItem.id) {
        return updatedItem;
      }

      return currentItem;
    }).toList();

    final updatedNote = note.copyWith(checklistItems: updatedItems);

    await updateNote(updatedNote);
  }

  Future<void> removeCheckListItem(Note note, String itemId) async {
    final updatedItem = note.checklistItems
        .where((item) => item.id != itemId)
        .toList();

    final updatedNote = note.copyWith(checklistItems: updatedItem);

    await updateNote(updatedNote);
  }

  List<Note> _filterNotes(NoteStatus status) {
    List<Note> filtered = _notes;
    filtered = filtered.where((note) => note.status == status).toList();

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

  void _sortNotes() {
    switch (_sortType) {
      case SortType.recent:
        _notes.sort((a, b) {
          if (a.isPinned != b.isPinned) {
            return a.isPinned ? -1 : 1;
          }
          return b.lastEdited.compareTo(a.lastEdited);
        });
        break;
      case SortType.alphabetical:
        _notes.sort((a, b) {
          if (a.isPinned != b.isPinned) {
            return a.isPinned ? -1 : 1;
          }
          return a.title.compareTo(b.title);
        });
        break;
    }
  }
}

import 'package:hive/hive.dart';

import '../models/note_model.dart';

class LocalNoteDatasources {
  late Box notesBox;
  late Box syncQueueBox;

  Future<void> init({required String userId}) async {
    notesBox = await Hive.openBox('notes_$userId');
    syncQueueBox = await Hive.openBox('sync_queue_$userId');
  }

  Future<void> addNote(NoteModel note) async {
    await notesBox.put(note.id, note.toMap());
  }

  Future<List<NoteModel>> getNotes() async {
    return notesBox.values
        .map((note) => NoteModel.fromMap(Map<String, dynamic>.from(note)))
        .toList();
  }

  Future<void> saveNotes(List<NoteModel> notes) async {
    final noteEntries = {for (final note in notes) note.id: note.toMap()};

    await notesBox.putAll(noteEntries);
  }

  Future<void> deleteNote(String id) async {
    await notesBox.delete(id);
  }

  Future<void> updateNote(NoteModel updatedNote) async {
    await notesBox.put(updatedNote.id, updatedNote.toMap());
  }

  Future<void> removeSyncOperationIfUnchanged({
    required String noteId,
    required String operationId,
  }) async {
    final current = syncQueueBox.get(noteId);

    if (current == null) return;

    final currentOperation = Map<String, dynamic>.from(current);

    if (currentOperation['operationId'] == operationId) {
      await syncQueueBox.delete(noteId);
    }
  }

  // Add or replace a pending operation for a note.
  Future<void> queueSyncOperation({
    required String noteId,
    required String operation,
    Map<String, dynamic>? noteData,
  }) async {
    await syncQueueBox.put(noteId, {
      'noteId': noteId,
      'operation': operation,
      'noteData': noteData,
      'queuedAt': DateTime.now().toIso8601String(),
      'operationId': DateTime.now().microsecondsSinceEpoch.toString(),
    });
  }

  // Read pending operations.
  List<Map<String, dynamic>> getPendingSyncOperations() {
    return syncQueueBox.values
        .map((value) => Map<String, dynamic>.from(value))
        .toList();
  }

  // Remove an operation only after cloud synchronization succeeds.
  Future<void> removeSyncOperation(String noteId) async {
    await syncQueueBox.delete(noteId);
  }

  void debugPrintPendingSyncOperations() {
    print('========== PENDING SYNC QUEUE ==========');
    print('Pending operations: ${syncQueueBox.length}');

    for (final value in syncQueueBox.values) {
      print(value);
    }

    print('=========================================');
  }
}

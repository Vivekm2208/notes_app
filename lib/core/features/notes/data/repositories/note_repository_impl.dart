import 'package:flutter/foundation.dart';
import 'package:notes_app/core/features/notes/data/datasources/firestore_note_datasources.dart';

import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repositories.dart';
import '../datasources/local_note_datasources.dart';
import '../models/note_model.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class NoteRepositoryImpl implements NoteRepositories {
  NoteRepositoryImpl(this.datasource, {required this.fireStoreNoteDataSources});

  final LocalNoteDatasources datasource;
  final FireStoreNoteDataSources fireStoreNoteDataSources;

  // Prevent overlapping sync attempts for the same note.
  final Set<String> _syncingNoteIds = {};
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isDisposed = false;

  void startSyncMonitoring() {
    _connectivitySubscription?.cancel();

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) {
      if (results.any((result) => result != ConnectivityResult.none)) {
        retryPendingSync();
      }
    });

    // Also attempt pending operations immediately.
    retryPendingSync();
  }

  Future<void> retryPendingSync() async {
    if (_isDisposed) return;

    final operations = datasource.getPendingSyncOperations();

    for (final operation in operations) {
      final noteId = operation['noteId'] as String?;
      if (noteId != null) {
        await _processPendingOperation(noteId);
      }
    }
  }

  Future<void> disposeSyncMonitoring() async {
    _isDisposed = true;
    await _connectivitySubscription?.cancel();
  }

  @override
  Future<void> addNote(Note note) async {
    final model = NoteModel.fromEntity(note);

    // Persist locally first.
    await datasource.addNote(model);

    // Persist the operation before attempting cloud sync.
    await datasource.queueSyncOperation(
      noteId: model.id,
      operation: 'upsert',
      noteData: model.toMap(),
    );
    datasource.debugPrintPendingSyncOperations();

    // Do not block the UI on Firestore.
    _processPendingOperation(model.id);
  }

  @override
  Future<void> updateNote(Note note) async {
    final model = NoteModel.fromEntity(note);

    await datasource.updateNote(model);

    await datasource.queueSyncOperation(
      noteId: model.id,
      operation: 'upsert',
      noteData: model.toMap(),
    );

    _processPendingOperation(model.id);
  }

  @override
  Future<void> deleteNote(String id) async {
    // Record deletion before removing the local copy.
    await datasource.queueSyncOperation(noteId: id, operation: 'delete');

    await datasource.deleteNote(id);

    _processPendingOperation(id);
  }

  Future<void> _processPendingOperation(String noteId) async {
    if (!_syncingNoteIds.add(noteId)) return;

    try {
      final operations = datasource.getPendingSyncOperations();

      Map<String, dynamic>? operation;

      for (final item in operations) {
        if (item['noteId'] == noteId) {
          operation = item;
          break;
        }
      }

      if (operation == null) return;

      // Read the operation ID only after finding the operation.
      final operationId = operation['operationId'] as String?;
      final type = operation['operation'] as String;

      if (type == 'delete') {
        await fireStoreNoteDataSources.deleteNote(noteId);
      } else if (type == 'upsert') {
        final data = Map<String, dynamic>.from(operation['noteData'] as Map);

        final model = NoteModel.fromMap(data);
        await fireStoreNoteDataSources.updateNote(model);
      } else {
        debugPrint('Unknown sync operation: $type');
        return;
      }

      // Remove only the operation that was actually synchronized.
      if (operationId != null) {
        await datasource.removeSyncOperationIfUnchanged(
          noteId: noteId,
          operationId: operationId,
        );
      }
    } catch (error, stackTrace) {
      debugPrint('Sync failed for note $noteId: $error');
      debugPrintStack(stackTrace: stackTrace);
      // Leave the operation queued for retry.
    } finally {
      _syncingNoteIds.remove(noteId);
    }
  }

  @override
  Future<List<Note>> getNotes() async {
    final localNotes = await datasource.getNotes();

    // Do not merge cloud data while local operations are pending.
    if (datasource.getPendingSyncOperations().isNotEmpty) {
      return List<Note>.from(localNotes);
    }

    try {
      final cloudNotes = await fireStoreNoteDataSources.getNote();

      await datasource.saveNotes(cloudNotes);

      return List<Note>.from(await datasource.getNotes());
    } catch (error, stackTrace) {
      debugPrint('Firestore getNotes failed: $error');
      debugPrintStack(stackTrace: stackTrace);

      return List<Note>.from(localNotes);
    }
  }
}

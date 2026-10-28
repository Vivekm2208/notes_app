import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/core/features/notes/data/datasources/firestore_note_datasources.dart';
import 'package:notes_app/core/features/notes/data/datasources/local_note_datasources.dart';
import 'package:notes_app/core/features/notes/data/repositories/note_repository_impl.dart';
import 'package:notes_app/core/features/notes/presentation/provider/notes_provider.dart';
import 'package:notes_app/core/features/notes/presentation/screens/notes_screen.dart';
import 'package:provider/provider.dart';

class AuthenticatedApp extends StatefulWidget {
  const AuthenticatedApp({super.key, required this.user});

  final User user;

  @override
  State<AuthenticatedApp> createState() => _AuthenticatedAppState();
}

class _AuthenticatedAppState extends State<AuthenticatedApp> {
  late final Future<LocalNoteDatasources> _datasourceFuture;
  late final Future<NoteRepositoryImpl> _repositoryFuture;

  @override
  void initState() {
    super.initState();
    _datasourceFuture = _initializeDatasource();
    _repositoryFuture = _initializeRepository();
  }

  Future<NoteRepositoryImpl> _initializeRepository() async {
    final datasource = await _datasourceFuture;

    final repository = NoteRepositoryImpl(
      datasource,
      fireStoreNoteDataSources: FireStoreNoteDataSources(
        userId: widget.user.uid,
      ),
    );

    repository.startSyncMonitoring();
    return repository;
  }

  Future<LocalNoteDatasources> _initializeDatasource() async {
    final datasource = LocalNoteDatasources();
    await datasource.init(userId: widget.user.uid);
    return datasource;
  }

  @override
  void dispose() {
    _repositoryFuture
        .then((repository) {
          repository.disposeSyncMonitoring();
        })
        .catchError((Object error) {
          debugPrint('Repository cleanup failed: $error');
        });

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<NoteRepositoryImpl>(
      future: _repositoryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          debugPrint('Repository initialization failed: ${snapshot.error}');

          return const Scaffold(
            body: Center(
              child: Text('Unable to load your notes. Please restart the app.'),
            ),
          );
        }

        return ChangeNotifierProvider<NotesProvider>(
          create: (_) =>
              NotesProvider(repositories: snapshot.data!)..loadNotes(),
          child: const _AuthenticatedNotesHost(),
        );
      },
    );
  }
}

class _AuthenticatedNotesHost extends StatelessWidget {
  const _AuthenticatedNotesHost();

  @override
  Widget build(BuildContext context) {
    return const NotesScreen();
  }
}

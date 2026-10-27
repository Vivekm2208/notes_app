import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _datasourceFuture = _initializeDatasource();
  }

  Future<LocalNoteDatasources> _initializeDatasource() async {
    final datasource = LocalNoteDatasources();
    await datasource.init(userId: widget.user.uid);
    return datasource;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LocalNoteDatasources>(
      future: _datasourceFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          debugPrint('Datasource initialization failed: ${snapshot.error}');

          return const Scaffold(
            body: Center(
              child: Text('Unable to load your notes. Please restart the app.'),
            ),
          );
        }

        final repository = NoteRepositoryImpl(snapshot.data!);

        return ChangeNotifierProvider<NotesProvider>(
          create: (_) => NotesProvider(repositories: repository)..loadNotes(),
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

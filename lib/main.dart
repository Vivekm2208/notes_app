import 'package:flutter/material.dart';
import 'core/features/notes/data/datasources/local_note_datasources.dart';
import 'core/features/notes/data/repositories/note_repository_impl.dart';
import 'core/features/notes/presentation/screens/notes_screen.dart';

void main() {
  final datasource = LocalNoteDatasources();

  final repository = NoteRepositoryImpl(datasource);

  runApp(MyApp(repository: repository));
}

class MyApp extends StatelessWidget {
  final NoteRepositoryImpl repository;

  const MyApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NotesScreen(repository: repository),
    );
  }
}

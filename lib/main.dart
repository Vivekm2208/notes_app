import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:notes_app/core/features/notes/presentation/provider/notes_provider.dart';
import 'core/features/notes/data/datasources/local_note_datasources.dart';
import 'core/features/notes/data/repositories/note_repository_impl.dart';
import 'core/features/notes/presentation/screens/notes_screen.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  final datasource = LocalNoteDatasources();

  await datasource.init();

  final repository = NoteRepositoryImpl(datasource);

  runApp(
    ChangeNotifierProvider(
      create: (_) => NotesProvider(repositories: repository)..loadNotes(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NotesScreen(),
    );
  }
}

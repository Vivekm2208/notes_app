import 'package:flutter/material.dart';
//import 'package:flutter_quill/flutter_quill.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:notes_app/core/features/notes/presentation/provider/notes_provider.dart';
import 'package:notes_app/core/features/notes/presentation/screens/login_screen.dart';
//import 'package:notes_app/core/features/rich_text_test/rich_text_test_screen.dart';
import 'package:notes_app/core/services/notification_service.dart';
import 'core/features/notes/data/datasources/local_note_datasources.dart';
import 'core/features/notes/data/repositories/note_repository_impl.dart';

import 'package:provider/provider.dart';
import 'package:notes_app/core/theme/app_theme.dart';
//import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  final datasource = LocalNoteDatasources();

  await datasource.init();

  final repository = NoteRepositoryImpl(datasource);

  await NotificationService.instance.initialize();

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
    return MaterialApp(
      theme: NotedTheme.light,
      darkTheme: NotedTheme.dark,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      // localizationsDelegates: const [
      //   GlobalMaterialLocalizations.delegate,
      //   GlobalCupertinoLocalizations.delegate,
      //   GlobalWidgetsLocalizations.delegate,
      //   FlutterQuillLocalizations.delegate,
      // ],

      // supportedLocales: FlutterQuillLocalizations.supportedLocales,
      home: const LoginScreen(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:notes_app/core/features/notes/presentation/screens/add_note_screen.dart';
import 'package:notes_app/core/features/notes/presentation/screens/edit_note_screen.dart';

import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repositories.dart';

class NotesScreen extends StatefulWidget {
  final NoteRepositories repository;

  const NotesScreen({super.key, required this.repository});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  late Future<List<Note>> notesFuture;

  @override
  void initState() {
    super.initState();

    notesFuture = widget.repository.getNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notes')),

      body: FutureBuilder<List<Note>>(
        future: notesFuture,

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No Notes'));
          }

          final notes = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notes.length,

            itemBuilder: (context, index) {
              final note = notes[index];

              return ListTile(
                title: Text(note.title),

                subtitle: Text(note.content),

                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditNoteScreen(
                              note: note,
                              repositories: widget.repository,
                            ),
                          ),
                        );
                        if (result == true) {
                          setState(() {
                            notesFuture = widget.repository.getNotes();
                          });
                        }
                      },
                      icon: Icon(Icons.edit),
                    ),
                    IconButton(
                      onPressed: () async {
                        final shouldDelete = await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Delete Note ?'),
                              content: Text(
                                'Are you sure you want to delete this note?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context, false);
                                  },
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context, true);
                                  },
                                  child: Text('Delete'),
                                ),
                              ],
                            );
                          },
                        );
                        if (shouldDelete == true) {
                          await widget.repository.deleteNote(note.id);

                          setState(() {
                            notesFuture = widget.repository.getNotes();
                          });
                        }
                      },
                      icon: const Icon(Icons.delete),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AddNoteScreen(repository: widget.repository),
            ),
          );
          if (result == true) {
            setState(() {
              notesFuture = widget.repository.getNotes();
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

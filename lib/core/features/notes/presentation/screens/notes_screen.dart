import 'package:flutter/material.dart';
import 'package:notes_app/core/features/notes/domain/entities/note.dart';
import 'package:notes_app/core/features/notes/presentation/provider/notes_provider.dart';
import 'package:notes_app/core/features/notes/presentation/screens/add_note_screen.dart';
import 'package:notes_app/core/features/notes/presentation/screens/edit_note_screen.dart';
import 'package:provider/provider.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotesProvider>();
    final notes = provider.filteredNotes;

    String capitalize(String text) {
      return text[0].toUpperCase() + text.substring(1);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DropdownButtonFormField<NoteCategory?>(
                    initialValue: provider.selectedCategory,
                    items: [
                      DropdownMenuItem<NoteCategory?>(
                        value: null,
                        child: Text('All'),
                      ),
                      ...NoteCategory.values.map((category) {
                        return DropdownMenuItem<NoteCategory?>(
                          value: category,
                          child: Text(capitalize(category.name)),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      context.read<NotesProvider>().updateSelectedCategory(
                        value,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search notes....',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      context.read<NotesProvider>().updateSearchQuery(value);
                    },
                  ),
                ),

                Expanded(
                  child: provider.notes.isEmpty
                      ? const Center(child: Text('No notes yet!'))
                      : notes.isEmpty
                      ? const Center(child: Text('No notes found!'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: notes.length,
                          itemBuilder: (context, index) {
                            final note = notes[index];
                            return ListTile(
                              title: Text(note.title),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(capitalize(note.category.name)),
                                  Text(note.content),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () async {
                                      await context
                                          .read<NotesProvider>()
                                          .togglePin(note);
                                    },
                                    icon: Icon(
                                      note.isPinned
                                          ? Icons.push_pin
                                          : Icons.push_pin_outlined,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              EditNoteScreen(note: note),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () async {
                                      final shouldDelete = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Delete Note?'),
                                          content: const Text(
                                            'Are you sure you want to delete this note?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (shouldDelete == true &&
                                          context.mounted) {
                                        await context
                                            .read<NotesProvider>()
                                            .deleteNote(note.id);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddNoteScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

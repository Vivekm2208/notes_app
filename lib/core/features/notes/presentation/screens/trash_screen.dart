import 'package:flutter/material.dart';
import 'package:notes_app/core/features/notes/presentation/provider/notes_provider.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/category_filterbar.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/note_card.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/note_search_field.dart';
import 'package:provider/provider.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/app_drawer.dart';

class TrashScreen extends StatelessWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotesProvider>();

    final notes = provider.trashedNotes;

    return Scaffold(
      drawer: AppDrawer(selected: DrawerItem.trash),
      appBar: AppBar(title: Text('Trash Bin')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: CategoryFilterbar(
              selectedCategory: provider.selectedCategory,
              onChanged: provider.updateSelectedCategory,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: NoteSearchfield(
              hintText: 'Search in Trash...',
              onChanged: provider.updateSearchQuery,
            ),
          ),
          Expanded(
            child: notes.isEmpty
                ? const Center(child: Text('Empty Trash Bin'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return NoteCard(
                        note: note,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.restore_from_trash),
                              onPressed: () async {
                                await context.read<NotesProvider>().restoreNote(
                                  note,
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_forever),
                              onPressed: () async {
                                final shouldDelete = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Forever?'),
                                    content: const Text(
                                      'Are you sure you want to delete this note forever?',
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
                                        child: const Text('Delete Forever'),
                                      ),
                                    ],
                                  ),
                                );
                                if (shouldDelete == true && context.mounted) {
                                  await context
                                      .read<NotesProvider>()
                                      .deleteForever(note.id);
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
    );
  }
}

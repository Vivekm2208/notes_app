import 'package:flutter/material.dart';
import 'package:notes_app/core/features/notes/presentation/provider/notes_provider.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/category_filterbar.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/note_card.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/note_search_field.dart';
import 'package:provider/provider.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/app_drawer.dart';

class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotesProvider>();

    final notes = provider.archivedNotes;

    return Scaffold(
      drawer: AppDrawer(selected: DrawerItem.archive),
      appBar: AppBar(title: const Text('Archived')),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CategoryFilterbar(
              selectedCategory: provider.selectedCategory,
              onChanged: provider.updateSelectedCategory,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: NoteSearchfield(
              hintText: 'Search Archive Notes...',
              onChanged: provider.updateSearchQuery,
            ),
          ),
          Expanded(
            child: notes.isEmpty
                ? const Center(child: Text('No Archived Notes'))
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
                              icon: const Icon(Icons.unarchive_outlined),
                              onPressed: () async {
                                await context.read<NotesProvider>().restoreNote(
                                  note,
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outlined),
                              onPressed: () async {
                                await context.read<NotesProvider>().moveToTrash(
                                  note,
                                );
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

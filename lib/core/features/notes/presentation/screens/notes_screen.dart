import 'package:flutter/material.dart';
import 'package:notes_app/core/features/notes/domain/entities/note.dart';
import 'package:notes_app/core/features/notes/presentation/provider/notes_provider.dart';
import 'package:notes_app/core/features/notes/presentation/screens/add_note_screen.dart';
import 'package:notes_app/core/features/notes/presentation/screens/edit_note_screen.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/category_filterbar.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/create_note_bottom_sheet.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/note_card.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/note_search_field.dart';
import 'package:provider/provider.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/app_drawer.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotesProvider>();
    final notes = provider.activeNotes;
    return Scaffold(
      drawer: AppDrawer(selected: DrawerItem.notes),
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          PopupMenuButton<SortType>(
            onSelected: (value) {
              context.read<NotesProvider>().updateSortType(value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: SortType.recent,
                child: Row(
                  children: [
                    Icon(Icons.schedule),
                    SizedBox(width: 8),
                    Text('Recently Edited'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: SortType.alphabetical,
                child: Row(
                  children: [
                    Icon(Icons.sort_by_alpha),
                    SizedBox(width: 8),
                    Text('Alphabetical'),
                  ],
                ),
              ),
            ],
            icon: Icon(Icons.sort),
          ),
        ],
      ),

      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
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
                    hintText: 'Search Notes...',
                    onChanged: provider.updateSearchQuery,
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

                            return NoteCard(
                              note: note,
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditNoteScreen(note: note),
                                  ),
                                );
                              },

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
                                            .moveToTrash(note);
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.archive_outlined),
                                    onPressed: () async {
                                      await context
                                          .read<NotesProvider>()
                                          .archiveNote(note);
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
          final type = await showModalBottomSheet<NoteType>(
            context: context,
            builder: (_) => const CreateNoteBottomSheet(),
          );

          if (type == null) return;

          if (!context.mounted) return;

          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddNoteScreen(type: type)),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

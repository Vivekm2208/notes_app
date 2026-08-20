import 'package:flutter/material.dart';
import 'package:notes_app/core/features/notes/domain/entities/note.dart';
import 'package:notes_app/core/features/notes/presentation/provider/notes_provider.dart';
import 'package:notes_app/core/features/notes/presentation/screens/add_note_screen.dart';
import 'package:notes_app/core/features/notes/presentation/screens/edit_note_screen.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/category_filterbar.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/create_note_bottom_sheet.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/note_action_sheet.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/note_card.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/note_search_field.dart';

import 'package:notes_app/core/theme/app_spacing.dart';
import 'package:provider/provider.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/app_drawer.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<StatefulWidget> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotesProvider>();
    final notes = provider.activeNotes;

    return Scaffold(
      //App Drawer
      drawer: AppDrawer(selected: DrawerItem.notes),
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: _isSearching
            //Searching feature
            ? NoteSearchfield(
                onChanged: context.read<NotesProvider>().updateSearchQuery,
              )
            : Text('NOTED', style: Theme.of(context).textTheme.titleLarge),

        elevation: 0,
        actions: [
          if (!_isSearching)
            IconButton(
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
              icon: const Icon(Icons.search_outlined),
            ),

          if (_isSearching)
            IconButton(
              onPressed: () {
                setState(() {
                  _isSearching = false;
                });
                context.read<NotesProvider>().updateSearchQuery('');
              },
              icon: const Icon(Icons.close),
            ),
          //Sorting feature
          PopupMenuButton<SortType>(
            onSelected: (value) {
              context.read<NotesProvider>().updateSortType(value);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: SortType.recent,
                child: Row(
                  children: [
                    Icon(Icons.schedule),
                    SizedBox(width: 8),
                    Text(
                      'Recently Edited',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: SortType.alphabetical,
                child: Row(
                  children: [
                    Icon(Icons.sort_by_alpha),
                    SizedBox(width: 8),
                    Text(
                      'Alphabetical',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
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
                  //Filter by category
                  child: CategoryFilterbar(
                    selectedCategory: provider.selectedCategory,
                    onChanged: provider.updateSelectedCategory,
                  ),
                ),
                const SizedBox(height: 12),

                Expanded(
                  child: provider.notes.isEmpty
                      ? const Center(child: Text('No notes yet!'))
                      : notes.isEmpty
                      ? const Center(child: Text('No notes found!'))
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: notes.length,
                          itemBuilder: (context, index) {
                            final note = notes[index];

                            return Dismissible(
                              key: ValueKey(note.id),
                              direction: DismissDirection.horizontal,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.only(
                                  right: NotedSpacing.md,
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.archive),
                                    Text(
                                      'Archive',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                  ],
                                ),
                              ),
                              secondaryBackground: Container(
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.only(left: NotedSpacing.md),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Delete',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                    Icon(Icons.delete_outlined),
                                  ],
                                ),
                              ),
                              onDismissed: (direction) async {
                                if (direction == DismissDirection.endToStart) {
                                  await context
                                      .read<NotesProvider>()
                                      .moveToTrash(note);
                                } else if (direction ==
                                    DismissDirection.startToEnd) {
                                  await context
                                      .read<NotesProvider>()
                                      .archiveNote(note);
                                }
                              },
                              //NoteCard
                              child: NoteCard(
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
                                onLongPress: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (context) {
                                      return NoteActionSheet(note: note);
                                    },
                                  );
                                },
                              ),
                            );
                          },
                          separatorBuilder: (context, index) {
                            return const SizedBox(height: 12);
                          },
                        ),
                ),
              ],
            ),
      /* ADD NOTE 
            Text/Checklist
             */
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
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

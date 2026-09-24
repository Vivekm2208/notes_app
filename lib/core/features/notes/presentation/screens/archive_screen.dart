import 'package:flutter/material.dart';
import 'package:notes_app/core/features/notes/presentation/provider/notes_provider.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/app_drawer.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/category_filterbar.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/note_search_field.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/notes_view_options.dart';
import 'package:provider/provider.dart';

class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotesProvider>();

    final notes = provider.archivedNotes;

    return Scaffold(
      drawer: AppDrawer(selected: DrawerItem.archive),

      appBar: AppBar(
        title: const Text('Archived'),

        actions: [
          IconButton(
            onPressed: () {
              final provider = context.read<NotesProvider>();

              provider.updateViewType(
                provider.viewType == NoteViewType.gridView
                    ? NoteViewType.listView
                    : NoteViewType.gridView,
              );
            },

            icon: Icon(
              provider.viewType == NoteViewType.gridView
                  ? Icons.view_list_outlined
                  : Icons.grid_view_outlined,
            ),
          ),
        ],
      ),

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
              hintText: 'Search Archive Notes...',
              onChanged: provider.updateSearchQuery,
            ),
          ),

          Expanded(
            child: notes.isEmpty
                ? const Center(child: Text('No Archived Notes'))
                : NotesViewOptions(
                    notes: notes,
                    onLeftSwipeText: 'Delete',
                    onLeftSwipe: (note) async {
                      await provider.moveToTrash(note);
                    },
                    onRghtSwipeText: 'Unarchive',
                    onRightSwipe: (note) async {
                      await provider.restoreNote(note);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

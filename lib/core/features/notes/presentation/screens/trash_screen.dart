import 'package:flutter/material.dart';
import 'package:notes_app/core/features/notes/presentation/provider/notes_provider.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/app_drawer.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/category_filterbar.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/note_search_field.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/notes_view_options.dart';
import 'package:provider/provider.dart';

class TrashScreen extends StatelessWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotesProvider>();

    final notes = provider.trashedNotes;

    return Scaffold(
      drawer: AppDrawer(selected: DrawerItem.trash),

      appBar: AppBar(
        title: const Text('Trash Bin'),

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
              hintText: 'Search in Trash...',
              onChanged: provider.updateSearchQuery,
            ),
          ),

          Expanded(
            child: notes.isEmpty
                ? const Center(child: Text('Empty Trash Bin'))
                : NotesViewOptions(
                    notes: notes,
                    onLeftSwipeText: 'Delete',
                    onLeftSwipe: (note) async {
                      await provider.deleteForever(note.id);
                    },
                    onRghtSwipeText: 'Restore',
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

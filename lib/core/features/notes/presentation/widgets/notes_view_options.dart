import 'package:flutter/material.dart';
import 'package:notes_app/core/features/notes/domain/entities/note.dart';
import 'package:notes_app/core/features/notes/presentation/provider/notes_provider.dart';
import 'package:notes_app/core/features/notes/presentation/screens/edit_note_screen.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/note_action_sheet.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/note_card.dart';
import 'package:notes_app/core/theme/app_spacing.dart';
import 'package:provider/provider.dart';

class NotesViewOptions extends StatelessWidget {
  const NotesViewOptions({
    super.key,
    required this.notes,
    required this.onRightSwipe,
    required this.onLeftSwipe,
    required this.onLeftSwipeText,
    required this.onRghtSwipeText,
  });

  final List<Note> notes;
  final Future<void> Function(Note note) onLeftSwipe;
  final String onLeftSwipeText;
  final String onRghtSwipeText;
  final Future<void> Function(Note note) onRightSwipe;

  // ----------------------------------------------------------
  // GRID VIEW
  // ----------------------------------------------------------

  Widget _buildGridView(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),

      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,

        // Start here and tune visually.
        childAspectRatio: 0.9,
      ),

      itemCount: notes.length,

      itemBuilder: (context, index) {
        final note = notes[index];

        return _buildNote(context, note);
      },
    );
  }

  // ----------------------------------------------------------
  // LIST VIEW
  // ----------------------------------------------------------

  Widget _buildListView(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),

      itemCount: notes.length,

      itemBuilder: (context, index) {
        final note = notes[index];

        return _buildNote(context, note);
      },

      separatorBuilder: (context, index) {
        return const SizedBox(height: 12);
      },
    );
  }

  // ----------------------------------------------------------
  // NOTE
  // ----------------------------------------------------------

  Widget _buildNote(BuildContext context, Note note) {
    return Dismissible(
      key: ValueKey(note.id),

      direction: DismissDirection.horizontal,

      // Swipe right → Archive
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: NotedSpacing.md),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.archive),
            const SizedBox(width: 8),
            Text(
              onRghtSwipeText,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),

      // Swipe left → Delete
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: NotedSpacing.md),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              onLeftSwipeText,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(width: 8),
            const Icon(Icons.delete_outlined),
          ],
        ),
      ),

      onDismissed: (direction) async {
        if (direction == DismissDirection.endToStart) {
          await onLeftSwipe(note);
        }

        if (direction == DismissDirection.startToEnd) {
          await onRightSwipe(note);
        }
      },

      child: NoteCard(
        note: note,

        // Global Grid/List preference
        viewType: context.read<NotesProvider>().viewType,

        onTap: () async {
          await Navigator.push(
            context,

            MaterialPageRoute(builder: (_) => EditNoteScreen(note: note)),
          );
        },

        onLongPress: () {
          showModalBottomSheet(
            context: context,
            builder: (_) {
              return NoteActionSheet(note: note);
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotesProvider>();

    return switch (provider.viewType) {
      NoteViewType.gridView => _buildGridView(context),
      NoteViewType.listView => _buildListView(context),
    };
  }
}

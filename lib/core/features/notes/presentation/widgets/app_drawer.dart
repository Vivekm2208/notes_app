import 'package:flutter/material.dart';
import 'package:notes_app/core/features/notes/presentation/screens/archive_screen.dart';
import 'package:notes_app/core/features/notes/presentation/screens/notes_screen.dart';
import 'package:notes_app/core/features/notes/presentation/screens/trash_screen.dart';

enum DrawerItem { notes, archive, trash }

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, required this.selected});

  final DrawerItem selected;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.notes, size: 40),
                SizedBox(height: 12),
                Text('NOTED', style: Theme.of(context).textTheme.titleMedium),

                Text(
                  'Organize your Ideas',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          ListTile(
            selected: selected == DrawerItem.notes,
            leading: const Icon(Icons.notes_outlined),
            title: Text(
              'Notes',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            onTap: () {
              if (selected != DrawerItem.notes) {
                Navigator.pop(context);

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const NotesScreen()),
                );
              } else {
                Navigator.pop(context);
              }
            },
          ),
          SizedBox(height: 8),
          ListTile(
            selected: selected == DrawerItem.archive,
            leading: const Icon(Icons.archive_outlined),
            title: Text(
              'Archived',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            onTap: () {
              if (selected != DrawerItem.archive) {
                Navigator.pop(context);

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const ArchiveScreen()),
                );
              } else {
                Navigator.pop(context);
              }
            },
          ),
          SizedBox(height: 8),
          ListTile(
            selected: selected == DrawerItem.trash,
            leading: const Icon(Icons.delete_outlined),
            title: Text(
              'Trash Bin',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            onTap: () {
              if (selected != DrawerItem.trash) {
                Navigator.pop(context);

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const TrashScreen()),
                );
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}

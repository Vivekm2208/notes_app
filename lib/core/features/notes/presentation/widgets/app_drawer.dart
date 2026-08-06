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
            decoration: const BoxDecoration(color: Colors.blue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.notes, color: Colors.white, size: 40),
                SizedBox(height: 12),
                const Text(
                  'Notes App',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  'Organize your Ideas',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          ListTile(
            selected: selected == DrawerItem.notes,
            leading: const Icon(Icons.notes_outlined),
            title: const Text('Notes'),
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
            title: const Text('Archive'),
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
            title: const Text('Trash Bin'),
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

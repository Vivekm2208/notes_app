import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/core/features/auth/data/services/auth_service.dart';
import 'package:notes_app/core/features/notes/presentation/provider/notes_provider.dart';
import 'package:notes_app/core/features/notes/presentation/screens/archive_screen.dart';
import 'package:notes_app/core/features/notes/presentation/screens/notes_screen.dart';
import 'package:notes_app/core/features/notes/presentation/screens/trash_screen.dart';
import 'package:provider/provider.dart';

enum DrawerItem { notes, archive, trash }

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, required this.selected});

  final DrawerItem selected;

  void _navigateTo(
    BuildContext context, {
    required DrawerItem destination,
    required Widget screen,
  }) {
    if (selected == destination) {
      Navigator.pop(context);
      return;
    }

    // Capture the existing provider before closing the drawer.
    final notesProvider = context.read<NotesProvider>();
    notesProvider.updateSearchQuery('');

    Navigator.pop(context);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider<NotesProvider>.value(
          value: notesProvider,
          child: screen,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.notes, size: 40),
                const SizedBox(height: 12),
                Text(
                  user?.displayName ?? 'NOTED',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (user?.email != null)
                  Text(
                    user!.email!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
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
            onTap: () => _navigateTo(
              context,
              destination: DrawerItem.notes,
              screen: const NotesScreen(),
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            selected: selected == DrawerItem.archive,
            leading: const Icon(Icons.archive_outlined),
            title: Text(
              'Archived',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            onTap: () => _navigateTo(
              context,
              destination: DrawerItem.archive,
              screen: const ArchiveScreen(),
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            selected: selected == DrawerItem.trash,
            leading: const Icon(Icons.delete_outlined),
            title: Text(
              'Trash Bin',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            onTap: () => _navigateTo(
              context,
              destination: DrawerItem.trash,
              screen: const TrashScreen(),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(
              'Logout',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            onTap: () async {
              Navigator.pop(context);

              try {
                await AuthService().signOut();
              } catch (e, stackTrace) {
                debugPrint('Logout error: $e');
                debugPrintStack(stackTrace: stackTrace);

                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Unable to log out. Please try again.'),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

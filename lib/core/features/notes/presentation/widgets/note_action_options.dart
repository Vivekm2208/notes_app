import 'package:flutter/material.dart';

class NoteActionOptions extends StatelessWidget {
  const NoteActionOptions({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      onTap: onTap,
    );
  }
}

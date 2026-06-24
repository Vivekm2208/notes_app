import 'package:flutter/material.dart';
import 'package:notes_app/core/features/notes/domain/entities/note.dart';
import 'package:notes_app/core/features/notes/presentation/provider/notes_provider.dart';
import 'package:provider/provider.dart';

class EditNoteScreen extends StatefulWidget {
  const EditNoteScreen({super.key, required this.note});

  final Note note;

  @override
  State<StatefulWidget> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  final _formkey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    titleController.text = widget.note.title;
    contentController.text = widget.note.content;
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formkey,
            child: Column(
              children: [
                const SizedBox(height: 16),
                TextFormField(
                  controller: titleController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Title can not be empty';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: contentController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Add some content';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(labelText: 'Content'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    if (_formkey.currentState!.validate()) {
                      final note = Note(
                        title: titleController.text,
                        id: widget.note.id,
                        content: contentController.text,
                      );
                      await context.read<NotesProvider>().updateNote(note);
                      if (!mounted) return;
                      Navigator.pop(context, true);
                    }
                  },
                  child: Text('Save Note'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

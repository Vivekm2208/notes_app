import 'package:flutter/material.dart';
import 'package:notes_app/core/features/notes/domain/entities/note.dart';
import 'package:notes_app/core/features/notes/domain/repositories/note_repositories.dart';

class EditNoteScreen extends StatefulWidget {
  const EditNoteScreen({
    super.key,
    required this.note,
    required this.repositories,
  });

  final Note note;
  final NoteRepositories repositories;

  @override
  State<StatefulWidget> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  final titlecontroller = TextEditingController();
  final contentcontroller = TextEditingController();

  final _formkey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    titlecontroller.text = widget.note.title;
    contentcontroller.text = widget.note.content;
  }

  @override
  void dispose() {
    titlecontroller.dispose();
    contentcontroller.dispose();
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
                SizedBox(height: 16),
                TextFormField(
                  controller: titlecontroller,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Title can not be empty';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: contentcontroller,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Add some content';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(labelText: 'Content'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    if (_formkey.currentState!.validate()) {
                      final note = Note(
                        title: titlecontroller.text,
                        id: widget.note.id,
                        content: contentcontroller.text,
                      );
                      await widget.repositories.updateNote(note);
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

import 'package:flutter/material.dart';
import 'package:notes_app/core/features/notes/domain/entities/checklist_item.dart';
import 'package:notes_app/core/features/notes/domain/entities/note.dart';
import 'package:notes_app/core/features/notes/presentation/provider/notes_provider.dart';
import 'package:notes_app/core/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/color_picker.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/checklist_editor.dart';
import 'package:notes_app/core/utils/id_generator.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/reminder_picker.dart';

class EditNoteScreen extends StatefulWidget {
  const EditNoteScreen({super.key, required this.note});

  final Note note;

  @override
  State<StatefulWidget> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  final contentController = TextEditingController();
  late NoteCategory selectedCategory;
  late Color selectedColor;
  late DateTime? selectedReminder;
  final titleController = TextEditingController();

  final _formkey = GlobalKey<FormState>();
  late List<ChecklistItem> _items;

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    titleController.text = widget.note.title;
    contentController.text = widget.note.content;
    selectedCategory = widget.note.category;
    selectedColor = Color(widget.note.colorValue);
    if (widget.note.type == NoteType.checklist) {
      _items = List.from(widget.note.checklistItems);
    }
    selectedReminder = widget.note.reminderAt;
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
                      return 'Add some decription';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(labelText: 'Description'),
                ),

                const SizedBox(height: 16),

                if (widget.note.type == NoteType.checklist)
                  ChecklistEditor(
                    items: _items,
                    onAdd: () {
                      setState(() {
                        _items.add(
                          ChecklistItem(
                            id: IdGenerator.generator(),
                            text: '',
                            isCompleted: false,
                          ),
                        );
                      });
                    },
                    onRemove: (id) {
                      setState(() {
                        _items.removeWhere((item) => item.id == id);
                      });
                    },
                    onToggle: (id) {
                      setState(() {
                        _items = _items.map((item) {
                          if (item.id == id) {
                            return item.copyWith(
                              isCompleted: !item.isCompleted,
                            );
                          }
                          return item;
                        }).toList();
                      });
                    },
                    onUpdate: (updatedItem) {
                      setState(() {
                        _items = _items.map((item) {
                          if (item.id == updatedItem.id) {
                            return updatedItem;
                          }
                          return item;
                        }).toList();
                      });
                    },
                  ),

                const SizedBox(height: 16),
                DropdownButtonFormField<NoteCategory>(
                  initialValue: selectedCategory,
                  items: NoteCategory.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                ColorPicker(
                  selectedColor: selectedColor,
                  onColorSelected: (color) {
                    setState(() {
                      selectedColor = color;
                    });
                  },
                ),
                SizedBox(height: 16),

                ReminderPicker(
                  reminder: selectedReminder,
                  onReminderChanged: (reminder) {
                    setState(() {
                      selectedReminder = reminder;
                    });
                  },
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    if (_formkey.currentState!.validate()) {
                      final notesProvider = context.read<NotesProvider>();
                      final messenger = ScaffoldMessenger.of(context);
                      final navigator = Navigator.of(context);

                      try {
                        final oldReminder = widget.note.reminderAt;
                        final newReminder = selectedReminder;
                        int? notificationId = widget.note.notificationId;
                        if (oldReminder != newReminder) {
                          if (oldReminder == null && newReminder != null) {
                            notificationId = DateTime.now()
                                .millisecondsSinceEpoch
                                .remainder(1 << 31);

                            await NotificationService.instance
                                .scheduleNotification(
                                  id: notificationId,
                                  title: titleController.text,
                                  body: contentController.text,
                                  scheduledTime: newReminder,
                                );
                          } else if (oldReminder != null &&
                              newReminder == null) {
                            await NotificationService.instance
                                .cancelNotification(
                                  widget.note.notificationId!,
                                );
                            notificationId = null;
                          } else {
                            await NotificationService.instance
                                .cancelNotification(
                                  widget.note.notificationId!,
                                );

                            notificationId = DateTime.now()
                                .millisecondsSinceEpoch
                                .remainder(1 << 31);

                            await NotificationService.instance
                                .scheduleNotification(
                                  id: notificationId,
                                  title: titleController.text,
                                  body: contentController.text,
                                  scheduledTime: newReminder!,
                                );
                          }
                        }
                        final now = DateTime.now();
                        final updatedNote = widget.note.copyWith(
                          title: titleController.text,
                          content: contentController.text,
                          checklistItems: widget.note.type == NoteType.checklist
                              ? _items
                              : widget.note.checklistItems,
                          category: selectedCategory,
                          colorValue: selectedColor.toARGB32(),
                          lastEdited: now,
                          reminderAt: selectedReminder,
                          notificationId: notificationId,
                        );
                        await notesProvider.updateNote(updatedNote);
                        if (!mounted) return;
                        navigator.pop(true);
                      } catch (e, stackTrace) {
                        debugPrint('Edit note error: $e');
                        debugPrintStack(stackTrace: stackTrace);

                        if (!mounted) return;

                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Unable to update note'),
                          ),
                        );
                      }
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

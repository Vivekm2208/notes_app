import 'package:flutter/material.dart';
import 'package:notes_app/core/features/notes/domain/entities/checklist_item.dart';
import 'package:notes_app/core/features/notes/domain/entities/note.dart';
import 'package:notes_app/core/features/notes/presentation/provider/notes_provider.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/checklist_editor.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/reminder_picker.dart';
import 'package:notes_app/core/services/notification_service.dart';
import 'package:notes_app/core/utils/id_generator.dart';
import 'package:provider/provider.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/color_picker.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key, required this.type});

  final NoteType type;

  @override
  State<StatefulWidget> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final now = DateTime.now();
  NoteCategory selectedCategory = NoteCategory.personal;
  Color selectedColor = Colors.white;
  DateTime? selectedReminder;

  final _contentController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  List<ChecklistItem> _items = [];
  final _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formkey,
            child: Column(
              children: [
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Title can not be empty';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 16),
                if (widget.type == NoteType.text)
                  TextFormField(
                    controller: _contentController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Add some content';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(labelText: 'Content'),
                  )
                else
                  Column(
                    children: [
                      TextFormField(
                        controller: _descriptionController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Add Checklist Description';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Description',
                        ),
                      ),
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
                        onRemove: (id) => setState(() {
                          _items.removeWhere((item) => item.id == id);
                        }),
                        onToggle: (id) => setState(() {
                          _items = _items.map((item) {
                            if (item.id == id) {
                              return item.copyWith(
                                isCompleted: !item.isCompleted,
                              );
                            }
                            return item;
                          }).toList();
                        }),
                        onUpdate: (updatedItem) => setState(() {
                          _items = _items.map((item) {
                            if (item.id == updatedItem.id) {
                              return updatedItem;
                            }
                            return item;
                          }).toList();
                        }),
                      ),
                    ],
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

                const SizedBox(height: 16),

                ReminderPicker(
                  reminder: selectedReminder,
                  onReminderChanged: (reminder) {
                    setState(() {
                      selectedReminder = reminder;
                    });
                  },
                ),

                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final content = widget.type == NoteType.text
                        ? _contentController.text
                        : _descriptionController.text;
                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(context);
                    final notesProvider = context.read<NotesProvider>();
                    int? notificationId;

                    if (_formkey.currentState!.validate()) {
                      if (selectedReminder != null) {
                        try {
                          notificationId = DateTime.now().millisecondsSinceEpoch
                              .remainder(1 << 31);
                          debugPrint('--------------------------------');
                          debugPrint('Current Time : ${DateTime.now()}');
                          debugPrint('Reminder Time: $selectedReminder');
                          debugPrint(
                            'Difference: ${selectedReminder!.difference(DateTime.now()).inSeconds} seconds',
                          );
                          debugPrint('--------------------------------');
                          await NotificationService.instance
                              .scheduleNotification(
                                id: notificationId,
                                title: _titleController.text,
                                body: content,
                                scheduledTime: selectedReminder!,
                              );
                          // await NotificationService.instance.showNotification();
                        } catch (e, stackTrace) {
                          debugPrint('Notification error: $e');
                          debugPrintStack(stackTrace: stackTrace);
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Unable to schedule reminder'),
                            ),
                          );

                          return;
                        }
                      }
                      final note = Note(
                        title: _titleController.text,
                        id: IdGenerator.generator(),
                        checklistItems: _items,
                        content: content,
                        category: selectedCategory,
                        colorValue: selectedColor.toARGB32(),
                        createdAt: now,
                        lastEdited: now,
                        type: widget.type,
                        reminderAt: selectedReminder,
                        notificationId: notificationId,
                      );
                      await notesProvider.addNote(note);
                      if (!mounted) return;
                      navigator.pop(true);
                    }
                  },
                  child: Text(
                    widget.type == NoteType.text
                        ? 'Save Note'
                        : 'Save Checklist',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

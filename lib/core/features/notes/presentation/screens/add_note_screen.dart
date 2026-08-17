import 'package:flutter/material.dart';
import 'package:notes_app/core/features/notes/domain/entities/checklist_item.dart';
import 'package:notes_app/core/features/notes/domain/entities/note.dart';
import 'package:notes_app/core/features/notes/presentation/provider/notes_provider.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/category_clip.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/checklist_editor.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/note_editor_header.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/note_editor_toolbar.dart';

import 'package:notes_app/core/services/notification_service.dart';
import 'package:notes_app/core/theme/app_spacing.dart';
import 'package:notes_app/core/utils/id_generator.dart';
import 'package:notes_app/core/utils/string_formatter.dart';
import 'package:provider/provider.dart';

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
  ReminderRecurrence selectedRecurrence = ReminderRecurrence.none;
  DateTime? selectedReminder;

  final _contentController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _focusedItemId;
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

  Future<void> _saveNote() async {
    {
      final content = widget.type == NoteType.text
          ? _contentController.text
          : _descriptionController.text;
      final messenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);
      final notesProvider = context.read<NotesProvider>();
      final recurrence = selectedReminder == null
          ? ReminderRecurrence.none
          : selectedRecurrence;
      int? notificationId;

      if (_formkey.currentState!.validate()) {
        if (selectedReminder != null) {
          try {
            notificationId = DateTime.now().millisecondsSinceEpoch.remainder(
              1 << 31,
            );
            debugPrint('--------------------------------');
            debugPrint('Current Time : ${DateTime.now()}');
            debugPrint('Reminder Time: $selectedReminder');
            debugPrint(
              'Difference: ${selectedReminder!.difference(DateTime.now()).inSeconds} seconds',
            );
            debugPrint('--------------------------------');
            await NotificationService.instance.scheduleNotification(
              id: notificationId,
              title: _titleController.text,
              body: content,
              scheduledTime: selectedReminder!,
              recurrence: selectedRecurrence,
            );
            // await NotificationService.instance.showNotification();
          } catch (e, stackTrace) {
            debugPrint('Notification error: $e');
            debugPrintStack(stackTrace: stackTrace);
            messenger.showSnackBar(
              const SnackBar(content: Text('Unable to schedule reminder')),
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
          recurrence: recurrence,
        );
        await notesProvider.addNote(note);
        if (!mounted) return;
        navigator.pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(),
            child: Form(
              key: _formkey,
              child: Column(
                children: [
                  NoteEditorHeader(
                    title: widget.type == NoteType.text
                        ? 'Text Note'
                        : 'Checklist',
                    onBack: () {
                      Navigator.pop(context);
                    },
                    onSave: _saveNote,
                  ),
                  const SizedBox(height: 16),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      spacing: NotedSpacing.sm,
                      children: [
                        ...NoteCategory.values.map((category) {
                          return CategoryClip(
                            onSelectedCategory: (value) {
                              setState(() {
                                selectedCategory = value!;
                              });
                            },
                            selectedCategory: selectedCategory,
                            label: StringFormatter.capitalize(category.name),
                            category: category,
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _titleController,
                    style: Theme.of(context).textTheme.titleLarge,
                    decoration: InputDecoration(
                      hintText: 'Title',
                      hintStyle: Theme.of(context).textTheme.titleLarge,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      border: InputBorder.none,
                    ),
                  ),
                  const SizedBox(height: 8),

                  if (widget.type == NoteType.text)
                    Expanded(
                      child: TextField(
                        maxLines: null,
                        textAlignVertical: TextAlignVertical.top,
                        controller: _contentController,
                        style: Theme.of(context).textTheme.bodyMedium,
                        decoration: InputDecoration(
                          hintText: 'Start Typing...',
                          hintStyle: Theme.of(context).textTheme.bodyMedium,
                          border: InputBorder.none,
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: Column(
                        children: [
                          TextField(
                            controller: _descriptionController,
                            textAlignVertical: TextAlignVertical.top,
                            style: Theme.of(context).textTheme.bodyMedium,
                            decoration: InputDecoration(
                              hintText: 'Add Description',
                              hintStyle: Theme.of(context).textTheme.bodyMedium,
                              border: InputBorder.none,
                            ),
                          ),

                          Expanded(
                            child: ChecklistEditor(
                              items: _items,
                              focusedItemId: _focusedItemId,

                              onAdd: () {
                                final id = IdGenerator.generator();

                                setState(() {
                                  _items.add(
                                    ChecklistItem(
                                      id: id,
                                      text: '',
                                      isCompleted: false,
                                    ),
                                  );

                                  _focusedItemId = id;
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
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),
                  NoteEditorToolbar(
                    selectedColor: selectedColor,
                    onSelectedColor: (color) {
                      setState(() {
                        selectedColor = color;
                      });
                    },
                    recurrence: selectedRecurrence,
                    onSelectedRecurrence: (recurrence) {
                      setState(() {
                        selectedRecurrence = recurrence;
                      });
                    },
                    reminder: selectedReminder,
                    onSelectedReminder: (reminder) {
                      setState(() {
                        selectedReminder = reminder;
                      });
                    },
                    onFormat: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

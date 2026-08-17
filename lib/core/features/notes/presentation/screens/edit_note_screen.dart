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

class EditNoteScreen extends StatefulWidget {
  const EditNoteScreen({super.key, required this.note});

  final Note note;

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  late NoteCategory selectedCategory;
  late Color selectedColor;
  late ReminderRecurrence selectedRecurrence;
  late DateTime? selectedReminder;

  late final TextEditingController _contentController;
  late final TextEditingController _descriptionController;
  late String? _focusedItemId;
  final _formKey = GlobalKey<FormState>();
  late List<ChecklistItem> _items;
  late final TextEditingController _titleController;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.note.title);

    _contentController = TextEditingController(
      text: widget.note.type == NoteType.text ? widget.note.content : '',
    );

    _descriptionController = TextEditingController(
      text: widget.note.type == NoteType.checklist ? widget.note.content : '',
    );

    selectedCategory = widget.note.category;
    selectedColor = Color(widget.note.colorValue);
    selectedReminder = widget.note.reminderAt;
    selectedRecurrence = widget.note.recurrence;

    _items = List<ChecklistItem>.from(widget.note.checklistItems);
    _focusedItemId = widget.note.id;
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final notesProvider = context.read<NotesProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final content = widget.note.type == NoteType.text
        ? _contentController.text
        : _descriptionController.text;

    // A recurrence without a reminder is invalid.
    final recurrence = selectedReminder == null
        ? ReminderRecurrence.none
        : selectedRecurrence;

    try {
      int? notificationId = widget.note.notificationId;

      /*
       * CASE 1:
       * Reminder was removed.
       */
      if (selectedReminder == null) {
        if (notificationId != null) {
          await NotificationService.instance.cancelNotification(notificationId);
        }

        notificationId = null;
      }
      /*
       * CASE 2:
       * A reminder exists.
       *
       * We use the existing notification ID when possible.
       * Scheduling with the same ID updates/replaces the
       * existing pending notification.
       */
      else {
        notificationId ??= DateTime.now().millisecondsSinceEpoch.remainder(
          1 << 31,
        );
        debugPrint('Reminder: $selectedReminder');
        debugPrint('Recurrence: $recurrence');
        debugPrint('Notification ID: $notificationId');
        await NotificationService.instance.scheduleNotification(
          id: notificationId,
          title: _titleController.text.trim(),
          body: content.trim(),
          scheduledTime: selectedReminder!,
          recurrence: recurrence,
        );
      }

      final updatedNote = widget.note.copyWith(
        title: _titleController.text.trim(),
        content: content,
        checklistItems: widget.note.type == NoteType.checklist
            ? _items
            : widget.note.checklistItems,
        category: selectedCategory,
        colorValue: selectedColor.toARGB32(),
        lastEdited: DateTime.now(),
        reminderAt: selectedReminder,
        notificationId: notificationId,
        recurrence: recurrence,
      );

      await notesProvider.updateNote(updatedNote);
      debugPrint('Updated reminder: ${updatedNote.reminderAt}');
      debugPrint('Updated recurrence: ${updatedNote.recurrence}');
      debugPrint('Updated notification ID: ${updatedNote.notificationId}');
      if (!mounted) return;

      navigator.pop(true);
    } catch (e, stackTrace) {
      debugPrint('Edit note error: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      messenger.showSnackBar(
        const SnackBar(content: Text('Unable to update note')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTextNote = widget.note.type == NoteType.text;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(NotedSpacing.md),
          child: Container(
            decoration: BoxDecoration(),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  NoteEditorHeader(
                    title: isTextNote ? 'Text Note' : 'Checklist',
                    onBack: () {
                      Navigator.pop(context);
                    },
                    onSave: _saveNote,
                  ),

                  const SizedBox(height: NotedSpacing.md),

                  /*
                   * CATEGORY
                   */
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      spacing: NotedSpacing.sm,
                      children: [
                        ...NoteCategory.values.map((category) {
                          return CategoryClip(
                            selectedCategory: selectedCategory,
                            label: StringFormatter.capitalize(category.name),
                            category: category,
                            onSelectedCategory: (value) {
                              setState(() {
                                selectedCategory = value!;
                              });
                            },
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: NotedSpacing.md),

                  /*
                   * TITLE
                   */
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

                  /*
                   * CONTENT / CHECKLIST
                   */
                  if (isTextNote)
                    Expanded(
                      child: TextField(
                        controller: _contentController,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        style: Theme.of(context).textTheme.bodyMedium,

                        decoration: InputDecoration(
                          hintText: 'Start Typing...',
                          hintStyle: Theme.of(context).textTheme.bodyMedium,
                          border: InputBorder.none,
                        ),
                      ),
                    )
                  else ...[
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

                    const SizedBox(height: NotedSpacing.md),

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

                  const SizedBox(height: NotedSpacing.md),

                  /*
                   * TOOLBAR
                   */
                  NoteEditorToolbar(
                    selectedColor: selectedColor,
                    onSelectedColor: (color) {
                      setState(() {
                        selectedColor = color;
                      });
                    },

                    reminder: selectedReminder,
                    onSelectedReminder: (reminder) {
                      setState(() {
                        selectedReminder = reminder;

                        if (reminder == null) {
                          selectedRecurrence = ReminderRecurrence.none;
                        }
                      });
                    },

                    recurrence: selectedRecurrence,
                    onSelectedRecurrence: (recurrence) {
                      setState(() {
                        selectedRecurrence = recurrence;
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

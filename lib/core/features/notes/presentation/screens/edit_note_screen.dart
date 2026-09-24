import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:notes_app/core/features/notes/domain/entities/checklist_item.dart';
import 'package:notes_app/core/features/notes/domain/entities/note.dart';
import 'package:notes_app/core/features/notes/presentation/provider/notes_provider.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/category_clip.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/checklist_editor.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/note_editor_header.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/note_editor_toolbar.dart';
import 'package:notes_app/core/services/notification_service.dart';
import 'package:notes_app/core/services/rich_text_converter.dart';
import 'package:notes_app/core/theme/app_radius.dart';
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
  late final QuillController _quillController;
  late final TextEditingController _titleController;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _descriptionController.dispose();
    if (widget.note.type == NoteType.text) {
      _quillController.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.note.title);

    _contentController = TextEditingController();
    if (widget.note.type == NoteType.text) {
      final document = widget.note.contentFormat == NoteContentFormat.plainText
          ? RichTextConverter.plainTextToDocument(widget.note.content)
          : RichTextConverter.jsonToDocument(widget.note.content);

      _quillController = QuillController(
        document: document,
        selection: const TextSelection.collapsed(offset: 0),
      );
    }
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

  String _getNotificationBody() {
    if (widget.note.type == NoteType.text) {
      return RichTextConverter.documentToPlainText(_quillController.document);
    }

    return _descriptionController.text.trim();
  }

  bool _isAttributeActive(Attribute attribute) {
    final style = _quillController.getSelectionStyle();

    return style.containsKey(attribute.key);
  }

  void _toggleAttribute(Attribute attribute) {
    final isActive = _isAttributeActive(attribute);

    if (isActive) {
      _quillController.formatSelection(Attribute.clone(attribute, null));
    } else {
      _quillController.formatSelection(attribute);
    }
  }

  bool _hasContent() {
    final title = _titleController.text.trim();

    if (widget.note.type == NoteType.text) {
      final content = _quillController.document.toPlainText().trim();

      return title.isNotEmpty || content.isNotEmpty;
    }

    final description = _descriptionController.text.trim();

    return title.isNotEmpty || description.isNotEmpty || _items.isNotEmpty;
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (!_hasContent()) {
      return;
    }

    final notesProvider = context.read<NotesProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final content = widget.note.type == NoteType.text
        ? RichTextConverter.documentToJsonString(_quillController.document)
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
          body: _getNotificationBody(),
          scheduledTime: selectedReminder!,
          recurrence: recurrence,
        );
      }

      final updatedNote = widget.note.copyWith(
        title: _titleController.text.trim(),
        content: content,
        contentFormat: widget.note.type == NoteType.text
            ? NoteContentFormat.richText
            : widget.note.contentFormat,
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

                  const SizedBox(height: 8),

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

                  const SizedBox(height: 4),

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

                  const SizedBox(height: 4),

                  /*
                   * CONTENT / CHECKLIST
                   */
                  if (isTextNote)
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          borderRadius: BorderRadius.circular(NotedRadius.sm),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: QuillEditor.basic(
                            controller: _quillController,
                          ),
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

                  const SizedBox(height: 8),

                  /*
                   * TOOLBAR
                   */
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      borderRadius: BorderRadius.circular(NotedRadius.sm),
                    ),
                    child: NoteEditorToolbar(
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
                      controller: isTextNote ? _quillController : null,
                      onFormat: (attribute) {
                        _toggleAttribute(attribute);
                      },
                    ),
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

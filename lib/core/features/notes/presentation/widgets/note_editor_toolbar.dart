import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/color_picker.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/format_toobar.dart';
import 'package:notes_app/core/features/notes/presentation/widgets/reminder_picker.dart';
import 'package:notes_app/core/theme/app_spacing.dart';
import 'package:notes_app/core/features/notes/domain/entities/note.dart';

class NoteEditorToolbar extends StatefulWidget {
  const NoteEditorToolbar({
    super.key,
    required this.selectedColor,
    required this.onSelectedColor,
    required this.reminder,
    required this.onSelectedReminder,
    required this.onFormat,
    required this.recurrence,
    required this.onSelectedRecurrence,
    required this.controller,
  });

  final QuillController? controller;
  final ValueChanged<Attribute> onFormat;
  final ValueChanged<Color> onSelectedColor;
  final ValueChanged<ReminderRecurrence> onSelectedRecurrence;
  final ValueChanged<DateTime?> onSelectedReminder;
  final ReminderRecurrence recurrence;
  final DateTime? reminder;
  final Color selectedColor;

  @override
  State<NoteEditorToolbar> createState() => _NoteEditorToolbarState();
}

class _NoteEditorToolbarState extends State<NoteEditorToolbar> {
  bool _showFormatToolbar = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ==============================
        // FORMAT TOOLBAR
        // ==============================
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: _showFormatToolbar && widget.controller != null
              ? Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: NotedSpacing.sm,
                      vertical: 4,
                    ),
                    child: FormatToolBar(
                      onFormat: widget.onFormat,
                      controller: widget.controller!,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),

        // ==============================
        // MAIN TOOLBAR
        // ==============================
        Row(
          children: [
            // COLOR
            Expanded(
              child: IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    builder: (context) {
                      return SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(NotedSpacing.md),
                          child: ColorPicker(
                            selectedColor: widget.selectedColor,
                            onColorSelected: (color) {
                              widget.onSelectedColor(color);
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
                icon: const Icon(Icons.color_lens_outlined),
              ),
            ),

            // REMINDER
            Expanded(
              child: IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) {
                      return SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(NotedSpacing.md),
                          child: ReminderPicker(
                            reminder: widget.reminder,
                            recurrence: widget.recurrence,
                            onReminderChanged: (reminder) {
                              widget.onSelectedReminder(reminder);
                              Navigator.pop(context);
                            },
                            onRecurrenceChanged: widget.onSelectedRecurrence,
                          ),
                        ),
                      );
                    },
                  );
                },
                icon: const Icon(Icons.notifications_active_outlined),
              ),
            ),

            // FORMAT
            if (widget.controller != null)
              Expanded(
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      _showFormatToolbar = !_showFormatToolbar;
                    });
                  },
                  icon: Icon(
                    Icons.text_format,
                    color: _showFormatToolbar
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

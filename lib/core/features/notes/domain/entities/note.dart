import 'package:notes_app/core/features/notes/domain/entities/checklist_item.dart';

enum NoteCategory { personal, study, work, ideas }

enum SortType { recent, alphabetical }

enum NoteStatus { active, archived, trashed }

enum NoteType { text, checklist }

enum ReminderRecurrence { none, daily, weekly, monthly, yearly }

class Note {
  const Note({
    required this.title,
    required this.id,
    required this.content,
    this.type = NoteType.text,
    this.checklistItems = const [],
    this.category = NoteCategory.personal,
    this.status = NoteStatus.active,
    this.colorValue = 0xFFFFFFFF,
    required this.createdAt,
    required this.lastEdited,
    this.reminderAt,
    this.notificationId,
    this.recurrence = ReminderRecurrence.none,
    this.isPinned = false,
  });

  final NoteCategory category;
  final List<ChecklistItem> checklistItems;
  final int colorValue;
  final String content;
  final DateTime createdAt;
  final String id;
  final bool isPinned;
  final DateTime lastEdited;
  final DateTime? reminderAt;
  final ReminderRecurrence recurrence;
  final int? notificationId;
  final NoteStatus status;
  final String title;
  final NoteType type;

  static const Object _unset = Object();

  Note copyWith({
    String? id,
    String? title,
    String? content,
    NoteType? type,
    List<ChecklistItem>? checklistItems,
    bool? isPinned,
    int? colorValue,
    NoteCategory? category,
    NoteStatus? status,
    DateTime? createdAt,
    DateTime? lastEdited,
    Object? reminderAt = _unset,
    ReminderRecurrence? recurrence,
    Object? notificationId = _unset,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      checklistItems: checklistItems ?? this.checklistItems,
      isPinned: isPinned ?? this.isPinned,
      colorValue: colorValue ?? this.colorValue,
      category: category ?? this.category,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      lastEdited: lastEdited ?? this.lastEdited,
      reminderAt: reminderAt == _unset
          ? this.reminderAt
          : reminderAt as DateTime?,
      recurrence: recurrence ?? this.recurrence,
      notificationId: notificationId == _unset
          ? this.notificationId
          : notificationId as int?,
    );
  }
}

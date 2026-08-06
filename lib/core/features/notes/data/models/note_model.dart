import '../../domain/entities/note.dart';
import 'package:notes_app/core/features/notes/data/models/checklist_item_model.dart';

class NoteModel extends Note {
  NoteModel({
    required super.id,
    required super.title,
    required super.content,
    required super.type,
    super.checklistItems = const [],
    super.isPinned = false,
    super.category = NoteCategory.personal,
    super.status = NoteStatus.active,
    super.colorValue = 0xFFFFFFFF,
    required super.createdAt,
    required super.lastEdited,
    super.reminderAt,
    super.notificationId,
  });

  factory NoteModel.fromEntity(Note note) {
    return NoteModel(
      id: note.id,
      title: note.title,
      content: note.content,
      type: note.type,
      checklistItems: note.checklistItems,
      isPinned: note.isPinned,
      category: note.category,
      status: note.status,
      colorValue: note.colorValue,
      createdAt: note.createdAt,
      lastEdited: note.lastEdited,
      reminderAt: note.reminderAt,
      notificationId: note.notificationId,
    );
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      type: NoteType.values.byName(map['type'] ?? 'text'),
      checklistItems:
          (map['checklistItems'] as List?)
              ?.map(
                (item) =>
                    ChecklistItemModel.fromMap(item as Map<String, dynamic>),
              )
              .toList() ??
          const [],

      isPinned: map['isPinned'] as bool? ?? false,
      category: NoteCategory.values.byName(map['category'] ?? 'personal'),
      status: NoteStatus.values.byName(map['status'] ?? 'active'),
      colorValue: map['colorValue'] as int? ?? 0xFFFFFFFF,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      lastEdited: map['lastEdited'] != null
          ? DateTime.parse(map['lastEdited'] as String)
          : DateTime.now(),
      reminderAt: map['reminderAt'] != null
          ? DateTime.parse(map['reminderAt'] as String)
          : null,
      notificationId: map['notificationId'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'type': type.name,
      'checklistItems': checklistItems
          .map((item) => ChecklistItemModel.fromEntity(item).toMap())
          .toList(),

      'isPinned': isPinned,

      'category': category.name,
      'status': status.name,
      'colorValue': colorValue,
      'createdAt': createdAt.toIso8601String(),
      'lastEdited': lastEdited.toIso8601String(),
      'reminderAt': reminderAt?.toIso8601String(),
      'notificationId': notificationId,
    };
  }
}

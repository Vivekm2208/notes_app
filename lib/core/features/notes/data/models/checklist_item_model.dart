import 'package:notes_app/core/features/notes/domain/entities/checklist_item.dart';

class ChecklistItemModel extends ChecklistItem {
  ChecklistItemModel({
    required super.id,
    required super.text,
    super.isCompleted = false,
  });

  factory ChecklistItemModel.fromEntity(ChecklistItem item) {
    return ChecklistItemModel(
      id: item.id,
      text: item.text,
      isCompleted: item.isCompleted,
    );
  }

  factory ChecklistItemModel.fromMap(Map<String, dynamic> map) {
    return ChecklistItemModel(
      id: map['id'] as String,
      text: map['text'] as String,
      isCompleted: map['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'text': text, 'isCompleted': isCompleted};
  }
}

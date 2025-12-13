// Data Layer - TodoItem Model mit DB-Mapping

import 'package:matzo/domain/entities/todo_item.dart';

class TodoItemModel extends TodoItem {
  const TodoItemModel({
    super.id,
    required super.categoryId,
    required super.title,
    super.count,
    super.order,
    super.isCompleted,
    required super.createdAt,
    super.completedAt,
  });

  // Von Domain Entity erstellen
  factory TodoItemModel.fromEntity(TodoItem item) {
    return TodoItemModel(
      id: item.id,
      categoryId: item.categoryId,
      title: item.title,
      count: item.count,
      order: item.order,
      isCompleted: item.isCompleted,
      createdAt: item.createdAt,
      completedAt: item.completedAt,
    );
  }

  // Von Datenbank Map erstellen
  factory TodoItemModel.fromMap(Map<String, dynamic> map) {
    return TodoItemModel(
      id: map['id'] as int?,
      categoryId: map['category_id'] as int,
      title: map['title'] as String,
      count: map['count'] as int? ?? 1,
        order: map['order_num'] as int? ?? 0,
      isCompleted: (map['is_completed'] as int) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      completedAt: map['completed_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['completed_at'] as int)
          : null,
    );
  }

  // Zu Datenbank Map konvertieren
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'category_id': categoryId,
      'title': title,
      'count': count,
      'order_num': order,
      'is_completed': isCompleted ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
      if (completedAt != null)
        'completed_at': completedAt!.millisecondsSinceEpoch,
    };
  }
}

// Data Layer - TodoItem Model mit DB-Mapping

import 'dart:convert';
import 'package:matzo/domain/entities/todo_item.dart';

class TodoItemModel extends TodoItem {
  const TodoItemModel({
    super.id,
    required super.categoryId,
    required super.title,
    super.count,
    super.order,
    super.originalOrder,
    super.isCompleted,
    required super.createdAt,
    super.completedAt,
    super.description,
    super.links,
  });

  // Von Domain Entity erstellen
  factory TodoItemModel.fromEntity(TodoItem item) {
    return TodoItemModel(
      id: item.id,
      categoryId: item.categoryId,
      title: item.title,
      count: item.count,
      order: item.order,
      originalOrder: item.originalOrder,
      isCompleted: item.isCompleted,
      createdAt: item.createdAt,
      completedAt: item.completedAt,
      description: item.description,
      links: item.links,
    );
  }

  // Von Datenbank Map erstellen
  factory TodoItemModel.fromMap(Map<String, dynamic> map) {
    // Links aus JSON String parsen
    List<String>? links;
    if (map['links'] != null && (map['links'] as String).isNotEmpty) {
      try {
        links = List<String>.from(jsonDecode(map['links'] as String));
      } catch (e) {
        links = null;
      }
    }

    return TodoItemModel(
      id: map['id'] as int?,
      categoryId: map['category_id'] as int,
      title: map['title'] as String,
      count: map['count'] as int? ?? 1,
      order: map['order_num'] as int? ?? 0,
      originalOrder: map['original_order'] as int?,
      isCompleted: (map['is_completed'] as int) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      completedAt: map['completed_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['completed_at'] as int)
          : null,
      description: map['description'] as String?,
      links: links,
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
      if (originalOrder != null) 'original_order': originalOrder,
      'is_completed': isCompleted ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
      if (completedAt != null)
        'completed_at': completedAt!.millisecondsSinceEpoch,
      if (description != null) 'description': description,
      if (links != null && links!.isNotEmpty) 'links': jsonEncode(links),
    };
  }
}

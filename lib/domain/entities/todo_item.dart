// Domain Layer - TodoItem Entity

import 'package:equatable/equatable.dart';

class TodoItem extends Equatable {
  final int? id;
  final int categoryId;
  final String title;
  final int count;
  final int order;
  final int? originalOrder; // Ursprüngliche Position vor dem Abhaken
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? description; // Mehrfach-Zeilen Beschreibung mit Bullet Points
  final List<String>? links; // Liste von URLs

  const TodoItem({
    this.id,
    required this.categoryId,
    required this.title,
    this.count = 1,
    this.order = 0,
    this.originalOrder,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
    this.description,
    this.links,
  });

  // Kopieren mit geänderten Werten
  TodoItem copyWith({
    int? id,
    int? categoryId,
    String? title,
    int? count,
    int? order,
    int? originalOrder,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
    String? description,
    List<String>? links,
  }) {
    return TodoItem(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      count: count ?? this.count,
      order: order ?? this.order,
      originalOrder: originalOrder ?? this.originalOrder,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      description: description ?? this.description,
      links: links ?? this.links,
    );
  }

  @override
  List<Object?> get props => [
        id,
        categoryId,
        title,
        count,
        order,
        originalOrder,
        isCompleted,
        createdAt,
        completedAt,
        description,
        links,
      ];
}

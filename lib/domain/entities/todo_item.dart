// Domain Layer - TodoItem Entity

import 'package:equatable/equatable.dart';

class TodoItem extends Equatable {
  final int? id;
  final int categoryId;
  final String title;
  final int count;
  final int order;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;

  const TodoItem({
    this.id,
    required this.categoryId,
    required this.title,
    this.count = 1,
    this.order = 0,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
  });

  // Kopieren mit geänderten Werten
  TodoItem copyWith({
    int? id,
    int? categoryId,
    String? title,
    int? count,
    int? order,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return TodoItem(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      count: count ?? this.count,
      order: order ?? this.order,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        categoryId,
        title,
        count,
        order,
        isCompleted,
        createdAt,
        completedAt,
      ];
}

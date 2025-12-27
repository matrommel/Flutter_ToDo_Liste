// Presentation - Category Screen States

import 'package:equatable/equatable.dart';
import 'package:matzo/domain/entities/category.dart';
import 'package:matzo/domain/entities/todo_item.dart';

abstract class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object?> get props => [];
}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final List<TodoItem> items;
  final List<Category> subcategories;
  final bool showCompleted;
  final bool showSubcategories;
  final bool sortAscending;

  const CategoryLoaded({
    required this.items,
    this.subcategories = const [],
    this.showCompleted = true,
    this.showSubcategories = true,
    this.sortAscending = true,
  });

  // Filtere offene Items
  List<TodoItem> get openItems =>
      items.where((item) => !item.isCompleted).toList();

  // Filtere erledigte Items
  List<TodoItem> get completedItems =>
      items.where((item) => item.isCompleted).toList();

  @override
  List<Object?> get props => [items, subcategories, showCompleted, showSubcategories, sortAscending];
}

class CategoryError extends CategoryState {
  final String message;

  const CategoryError({required this.message});

  @override
  List<Object?> get props => [message];
}

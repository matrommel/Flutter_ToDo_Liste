// Domain Layer - TodoItem Repository Interface

import 'package:matzo/domain/entities/todo_item.dart';

abstract class TodoItemRepository {
  Future<List<TodoItem>> getItemsByCategory(int categoryId);
  Future<TodoItem?> getItemById(int id);
  Future<int> addItem(TodoItem item);
  Future<void> updateItem(TodoItem item);
  Future<void> deleteItem(int id);
  Future<void> toggleItemCompletion(int id);
  Future<void> updateItemCount(int id, int newCount);
  Future<void> updateItemOrder(int id, int newOrder);
}

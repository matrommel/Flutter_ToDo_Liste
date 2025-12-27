// Data Layer - Interface für TodoItem Datasource

import 'package:matzo/data/models/todo_item_model.dart';

abstract class ITodoItemLocalDataSource {
  Future<List<TodoItemModel>> getItemsByCategory(int categoryId);
  Future<TodoItemModel?> getItemById(int id);
  Future<int> insertItem(TodoItemModel item);
  Future<void> updateItem(TodoItemModel item);
  Future<void> deleteItem(int id);
  Future<void> toggleItemCompletion(int id);
  Future<void> updateItemCount(int id, int newCount);
  Future<void> updateItemOrder(int id, int newOrder);
}

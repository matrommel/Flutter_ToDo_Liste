// Data Layer - TodoItemRepository Implementation

import 'package:matzo/domain/entities/todo_item.dart';
import 'package:matzo/domain/repositories/todo_item_repository.dart';
import 'package:matzo/data/datasources/local/todo_item_local_datasource.dart';
import 'package:matzo/data/models/todo_item_model.dart';

class TodoItemRepositoryImpl implements TodoItemRepository {
  final TodoItemLocalDataSource localDataSource;

  TodoItemRepositoryImpl(this.localDataSource);

  @override
  Future<List<TodoItem>> getItemsByCategory(int categoryId) async {
    return await localDataSource.getItemsByCategory(categoryId);
  }

  @override
  Future<TodoItem?> getItemById(int id) async {
    return await localDataSource.getItemById(id);
  }

  @override
  Future<int> addItem(TodoItem item) async {
    final model = TodoItemModel.fromEntity(item);
    return await localDataSource.insertItem(model);
  }

  @override
  Future<void> updateItem(TodoItem item) async {
    final model = TodoItemModel.fromEntity(item);
    await localDataSource.updateItem(model);
  }

  @override
  Future<void> deleteItem(int id) async {
    await localDataSource.deleteItem(id);
  }

  @override
  Future<void> toggleItemCompletion(int id) async {
    await localDataSource.toggleItemCompletion(id);
  }

  @override
  Future<void> updateItemCount(int id, int newCount) async {
    await localDataSource.updateItemCount(id, newCount);
  }

  @override
  Future<void> updateItemOrder(int id, int newOrder) async {
    await localDataSource.updateItemOrder(id, newOrder);
  }
}

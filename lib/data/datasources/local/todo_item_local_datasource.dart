// Data Layer - Lokale Datenquelle für Todo-Items

import 'package:matzo/data/models/todo_item_model.dart';
import 'package:matzo/data/datasources/local/database_helper.dart';
import 'package:matzo/data/datasources/local/i_todo_item_local_datasource.dart';

class TodoItemLocalDataSource implements ITodoItemLocalDataSource {
  final DatabaseHelper dbHelper;

  TodoItemLocalDataSource(this.dbHelper);

  Future<List<TodoItemModel>> getItemsByCategory(int categoryId) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'todo_items',
      where: 'category_id = ?',
      whereArgs: [categoryId],
      orderBy: 'order_num ASC, created_at ASC',
    );
    return maps.map((map) => TodoItemModel.fromMap(map)).toList();
  }

  Future<TodoItemModel?> getItemById(int id) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'todo_items',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return TodoItemModel.fromMap(maps.first);
  }

  Future<int> insertItem(TodoItemModel item) async {
    final db = await dbHelper.database;
    return await db.insert('todo_items', item.toMap());
  }

  Future<void> updateItem(TodoItemModel item) async {
    final db = await dbHelper.database;
    await db.update(
      'todo_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<void> deleteItem(int id) async {
    final db = await dbHelper.database;
    await db.delete(
      'todo_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> toggleItemCompletion(int id) async {
    final db = await dbHelper.database;
    
    // Aktuellen Status holen
    final item = await getItemById(id);
    if (item == null) return;

    // Status umkehren
    final newStatus = !item.isCompleted;
    final completedAt = newStatus ? DateTime.now().millisecondsSinceEpoch : null;

    await db.update(
      'todo_items',
      {
        'is_completed': newStatus ? 1 : 0,
        'completed_at': completedAt,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateItemCount(int id, int newCount) async {
    final db = await dbHelper.database;
    await db.update(
      'todo_items',
      {'count': newCount},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateItemOrder(int id, int newOrder) async {
    final db = await dbHelper.database;
    await db.update(
      'todo_items',
      {'order_num': newOrder},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

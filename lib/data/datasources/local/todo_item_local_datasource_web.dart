// Data Layer - Web In-Memory Datenquelle für Todo Items

import 'package:hive_flutter/hive_flutter.dart';
import 'package:matzo/data/models/todo_item_model.dart';
import 'package:matzo/data/datasources/local/i_todo_item_local_datasource.dart';

class TodoItemLocalDataSourceWeb implements ITodoItemLocalDataSource {
  static const String _boxName = 'todo_items';
  Box<Map>? _box;

  Future<void> _ensureBox() async {
    if (_box == null || !_box!.isOpen) {
      if (!Hive.isBoxOpen(_boxName)) {
        _box = await Hive.openBox<Map>(_boxName);
      } else {
        _box = Hive.box<Map>(_boxName);
      }
    }
  }

  Future<List<TodoItemModel>> getItemsByCategory(int categoryId) async {
    await _ensureBox();
    final items = _box!.values
        .map((map) => TodoItemModel.fromMap(Map<String, dynamic>.from(map)))
        .where((item) => item.categoryId == categoryId)
        .toList();
    items.sort((a, b) {
      final orderCompare = a.order.compareTo(b.order);
      if (orderCompare != 0) return orderCompare;
      return a.createdAt.compareTo(b.createdAt);
    });
    return items;
  }

  Future<TodoItemModel?> getItemById(int id) async {
    await _ensureBox();
    final map = _box!.get(id);
    if (map == null) return null;
    return TodoItemModel.fromMap(Map<String, dynamic>.from(map));
  }

  Future<int> insertItem(TodoItemModel item) async {
    await _ensureBox();
    final id = _box!.isEmpty ? 1 : (_box!.keys.cast<int>().reduce((a, b) => a > b ? a : b) + 1);
    final itemWithId = TodoItemModel(
      id: id,
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
    await _box!.put(id, itemWithId.toMap());
    return id;
  }

  Future<void> updateItem(TodoItemModel item) async {
    await _ensureBox();
    await _box!.put(item.id!, item.toMap());
  }

  Future<void> deleteItem(int id) async {
    await _ensureBox();
    await _box!.delete(id);
  }

  Future<void> toggleItemCompletion(int id) async {
    final item = await getItemById(id);
    if (item == null) return;

    final newStatus = !item.isCompleted;
    int newOrder = item.order;
    int? newOriginalOrder = item.originalOrder;

    if (newStatus) {
      // Abhaken: Ursprüngliche Position speichern und ans Ende verschieben
      final allItems = await getItemsByCategory(item.categoryId);
      final maxOrder = allItems.isEmpty ? 0 : allItems.map((e) => e.order).reduce((a, b) => a > b ? a : b);

      newOriginalOrder = item.order; // Ursprüngliche Position speichern
      newOrder = maxOrder + 1; // Ans Ende verschieben
    } else {
      // Wiederaktivieren: Ursprüngliche Position wiederherstellen
      if (item.originalOrder != null) {
        newOrder = item.originalOrder!;
        newOriginalOrder = null; // originalOrder zurücksetzen
      }
    }

    final updated = TodoItemModel(
      id: item.id,
      categoryId: item.categoryId,
      title: item.title,
      count: item.count,
      order: newOrder,
      originalOrder: newOriginalOrder,
      isCompleted: newStatus,
      createdAt: item.createdAt,
      completedAt: newStatus ? DateTime.now() : null,
      description: item.description,
      links: item.links,
    );
    await updateItem(updated);
  }

  Future<void> updateItemCount(int id, int newCount) async {
    final item = await getItemById(id);
    if (item == null) return;

    final updated = TodoItemModel(
      id: item.id,
      categoryId: item.categoryId,
      title: item.title,
      count: newCount,
      order: item.order,
      originalOrder: item.originalOrder,
      isCompleted: item.isCompleted,
      createdAt: item.createdAt,
      completedAt: item.completedAt,
      description: item.description,
      links: item.links,
    );
    await updateItem(updated);
  }

  Future<void> updateItemOrder(int id, int newOrder) async {
    final item = await getItemById(id);
    if (item == null) return;

    final updated = TodoItemModel(
      id: item.id,
      categoryId: item.categoryId,
      title: item.title,
      count: item.count,
      order: newOrder,
      originalOrder: item.originalOrder,
      isCompleted: item.isCompleted,
      createdAt: item.createdAt,
      completedAt: item.completedAt,
      description: item.description,
      links: item.links,
    );
    await updateItem(updated);
  }
}

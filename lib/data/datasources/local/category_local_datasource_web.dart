// Data Layer - Web In-Memory Datenquelle für Kategorien

import 'package:hive_flutter/hive_flutter.dart';
import 'package:matzo/data/models/category_model.dart';
import 'package:matzo/data/datasources/local/i_category_local_datasource.dart';

class CategoryLocalDataSourceWeb implements ICategoryLocalDataSource {
  static const String _boxName = 'categories';
  Box<Map>? _box;

  Future<void> _ensureBox() async {
    if (_box == null || !_box!.isOpen) {
      await Hive.initFlutter();
      _box = await Hive.openBox<Map>(_boxName);
    }
  }

  Future<List<CategoryModel>> getAllCategories() async {
    await _ensureBox();
    final categories = _box!.values.map((map) {
      return CategoryModel.fromMap(Map<String, dynamic>.from(map));
    }).toList();
    categories.sort((a, b) => a.order.compareTo(b.order));
    return categories;
  }

  Future<CategoryModel?> getCategoryById(int id) async {
    await _ensureBox();
    final map = _box!.get(id);
    if (map == null) return null;
    return CategoryModel.fromMap(Map<String, dynamic>.from(map));
  }

  Future<int> insertCategory(CategoryModel category) async {
    await _ensureBox();
    final id = _box!.isEmpty ? 1 : (_box!.keys.cast<int>().reduce((a, b) => a > b ? a : b) + 1);
    final categoryWithId = CategoryModel(
      id: id,
      name: category.name,
      createdAt: category.createdAt,
      order: category.order,
      iconCodePoint: category.iconCodePoint,
      isProtected: category.isProtected,
    );
    await _box!.put(id, categoryWithId.toMap());
    return id;
  }

  Future<void> updateCategory(CategoryModel category) async {
    await _ensureBox();
    await _box!.put(category.id!, category.toMap());
  }

  Future<void> deleteCategory(int id) async {
    await _ensureBox();
    await _box!.delete(id);
  }

  Future<int> getCategoryItemCount(int categoryId) async {
    // Zähle Items aus der TodoItems Box
    if (!Hive.isBoxOpen('todo_items')) {
      await Hive.openBox<Map>('todo_items');
    }
    final todoBox = Hive.box<Map>('todo_items');

    int count = 0;
    for (final map in todoBox.values) {
      final itemMap = Map<String, dynamic>.from(map);
      if (itemMap['category_id'] == categoryId &&
          (itemMap['is_completed'] as int) == 0) {
        count++;
      }
    }
    return count;
  }

  Future<void> updateCategoryProtection(int categoryId, bool isProtected) async {
    await _ensureBox();
    final map = _box!.get(categoryId);
    if (map != null) {
      final category = CategoryModel.fromMap(Map<String, dynamic>.from(map));
      final updated = CategoryModel(
        id: category.id,
        name: category.name,
        createdAt: category.createdAt,
        order: category.order,
        iconCodePoint: category.iconCodePoint,
        isProtected: isProtected,
      );
      await _box!.put(categoryId, updated.toMap());
    }
  }
}

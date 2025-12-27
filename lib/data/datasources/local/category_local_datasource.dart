// Data Layer - Lokale Datenquelle für Kategorien

import 'package:matzo/data/models/category_model.dart';
import 'package:matzo/data/datasources/local/database_helper.dart';
import 'package:matzo/data/datasources/local/i_category_local_datasource.dart';

class CategoryLocalDataSource implements ICategoryLocalDataSource {
  final DatabaseHelper dbHelper;

  CategoryLocalDataSource(this.dbHelper);

  Future<List<CategoryModel>> getAllCategories() async {
    final db = await dbHelper.database;
    final maps = await db.query('categories');
    return maps.map((map) => CategoryModel.fromMap(map)).toList();
  }

  Future<CategoryModel?> getCategoryById(int id) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return CategoryModel.fromMap(maps.first);
  }

  Future<int> insertCategory(CategoryModel category) async {
    final db = await dbHelper.database;
    return await db.insert('categories', category.toMap());
  }

  Future<void> updateCategory(CategoryModel category) async {
    final db = await dbHelper.database;
    await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<void> deleteCategory(int id) async {
    final db = await dbHelper.database;
    await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Zähle offene Items in einer Kategorie
  Future<int> getCategoryItemCount(int categoryId) async {
    final db = await dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM todo_items WHERE category_id = ? AND is_completed = 0',
      [categoryId],
    );
    if (result.isEmpty) return 0;
    final count = result.first['count'];
    return (count is int) ? count : int.tryParse(count.toString()) ?? 0;
  }

  // Aktualisiere Biometrie-Schutz für Kategorie
  Future<void> updateCategoryProtection(int categoryId, bool isProtected) async {
    final db = await dbHelper.database;
    await db.update(
      'categories',
      {'is_protected': isProtected ? 1 : 0},
      where: 'id = ?',
      whereArgs: [categoryId],
    );
  }

  @override
  Future<List<CategoryModel>> getTopLevelCategories() async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'categories',
      where: 'parent_category_id IS NULL',
      orderBy: 'order_num ASC',
    );
    return maps.map((map) => CategoryModel.fromMap(map)).toList();
  }

  @override
  Future<List<CategoryModel>> getSubcategories(int parentId) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'categories',
      where: 'parent_category_id = ?',
      whereArgs: [parentId],
      orderBy: 'order_num ASC',
    );
    return maps.map((map) => CategoryModel.fromMap(map)).toList();
  }

  @override
  Future<int> getRecursiveItemCount(int categoryId) async {
    final db = await dbHelper.database;

    // Rekursive CTE für alle Unter-Kategorien
    final result = await db.rawQuery('''
      WITH RECURSIVE subcategories AS (
        SELECT id FROM categories WHERE id = ?
        UNION ALL
        SELECT c.id FROM categories c
        INNER JOIN subcategories s ON c.parent_category_id = s.id
      )
      SELECT COUNT(*) as count FROM todo_items
      WHERE category_id IN (SELECT id FROM subcategories)
      AND is_completed = 0
    ''', [categoryId]);

    if (result.isEmpty) return 0;
    final count = result.first['count'];
    return (count is int) ? count : int.tryParse(count.toString()) ?? 0;
  }

  @override
  Future<int> getRecursiveTotalItemCount(int categoryId) async {
    final db = await dbHelper.database;

    // Rekursive CTE für alle Unter-Kategorien - ALLE Items (inkl. completed)
    final result = await db.rawQuery('''
      WITH RECURSIVE subcategories AS (
        SELECT id FROM categories WHERE id = ?
        UNION ALL
        SELECT c.id FROM categories c
        INNER JOIN subcategories s ON c.parent_category_id = s.id
      )
      SELECT COUNT(*) as count FROM todo_items
      WHERE category_id IN (SELECT id FROM subcategories)
    ''', [categoryId]);

    if (result.isEmpty) return 0;
    final count = result.first['count'];
    return (count is int) ? count : int.tryParse(count.toString()) ?? 0;
  }

  @override
  Future<int> getSubcategoryCount(int categoryId) async {
    final db = await dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM categories WHERE parent_category_id = ?',
      [categoryId],
    );
    if (result.isEmpty) return 0;
    final count = result.first['count'];
    return (count is int) ? count : int.tryParse(count.toString()) ?? 0;
  }
}

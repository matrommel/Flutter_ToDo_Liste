// Data Layer - Lokale Datenquelle für Kategorien

import 'package:sqflite/sqflite.dart';
import 'package:matzo/data/models/category_model.dart';
import 'package:matzo/data/datasources/local/database_helper.dart';

class CategoryLocalDataSource {
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
    return Sqflite.firstIntValue(result) ?? 0;
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
}

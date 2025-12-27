// Domain Layer - Repository Interface
// Definiert WAS gemacht werden kann, nicht WIE

import 'package:matzo/domain/entities/category.dart';

abstract class CategoryRepository {
  Future<List<Category>> getAllCategories();
  Future<List<Category>> getTopLevelCategories(); // Nur Top-Level (parentId = NULL)
  Future<List<Category>> getSubcategories(int parentId); // Unterkategorien einer Kategorie
  Future<Category?> getCategoryById(int id);
  Future<int> addCategory(Category category);
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(int id);
  Future<int> getCategoryItemCount(int categoryId);
  Future<int> getRecursiveItemCount(int categoryId); // Rekursiv alle OFFENEN Items zählen
  Future<int> getRecursiveTotalItemCount(int categoryId); // Rekursiv ALLE Items zählen (inkl. completed)
  Future<int> getSubcategoryCount(int categoryId); // Anzahl der direkten Unterkategorien
  Future<void> updateCategoryProtection(int categoryId, bool isProtected);
}

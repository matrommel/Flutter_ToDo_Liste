// Domain Layer - Repository Interface
// Definiert WAS gemacht werden kann, nicht WIE

import 'package:matzo/domain/entities/category.dart';

abstract class CategoryRepository {
  Future<List<Category>> getAllCategories();
  Future<Category?> getCategoryById(int id);
  Future<int> addCategory(Category category);
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(int id);
  Future<int> getCategoryItemCount(int categoryId);
}

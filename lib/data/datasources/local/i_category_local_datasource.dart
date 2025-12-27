// Data Layer - Interface für Category Datasource

import 'package:matzo/data/models/category_model.dart';

abstract class ICategoryLocalDataSource {
  Future<List<CategoryModel>> getAllCategories();
  Future<List<CategoryModel>> getTopLevelCategories();
  Future<List<CategoryModel>> getSubcategories(int parentId);
  Future<CategoryModel?> getCategoryById(int id);
  Future<int> insertCategory(CategoryModel category);
  Future<void> updateCategory(CategoryModel category);
  Future<void> deleteCategory(int id);
  Future<int> getCategoryItemCount(int categoryId);
  Future<int> getRecursiveItemCount(int categoryId);
  Future<int> getRecursiveTotalItemCount(int categoryId);
  Future<int> getSubcategoryCount(int categoryId);
  Future<void> updateCategoryProtection(int categoryId, bool isProtected);
}

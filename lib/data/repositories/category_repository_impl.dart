// Data Layer - CategoryRepository Implementation

import 'package:matzo/domain/entities/category.dart';
import 'package:matzo/domain/repositories/category_repository.dart';
import 'package:matzo/data/datasources/local/i_category_local_datasource.dart';
import 'package:matzo/data/models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final ICategoryLocalDataSource localDataSource;

  CategoryRepositoryImpl(this.localDataSource);

  @override
  Future<List<Category>> getAllCategories() async {
    return await localDataSource.getAllCategories();
  }

  @override
  Future<Category?> getCategoryById(int id) async {
    return await localDataSource.getCategoryById(id);
  }

  @override
  Future<int> addCategory(Category category) async {
    final model = CategoryModel.fromEntity(category);
    return await localDataSource.insertCategory(model);
  }

  @override
  Future<void> updateCategory(Category category) async {
    final model = CategoryModel.fromEntity(category);
    await localDataSource.updateCategory(model);
  }

  @override
  Future<void> deleteCategory(int id) async {
    await localDataSource.deleteCategory(id);
  }

  @override
  Future<int> getCategoryItemCount(int categoryId) async {
    return await localDataSource.getCategoryItemCount(categoryId);
  }

  @override
  Future<void> updateCategoryProtection(int categoryId, bool isProtected) async {
    await localDataSource.updateCategoryProtection(categoryId, isProtected);
  }
}

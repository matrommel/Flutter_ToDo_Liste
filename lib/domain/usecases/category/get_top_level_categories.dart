// Domain Layer - Use Case für das Abrufen der Top-Level Kategorien

import 'package:matzo/domain/entities/category.dart';
import 'package:matzo/domain/repositories/category_repository.dart';

class GetTopLevelCategories {
  final CategoryRepository repository;

  GetTopLevelCategories(this.repository);

  Future<List<Category>> call() async {
    final categories = await repository.getTopLevelCategories();
    // Sortierung erfolgt bereits im Repository
    return categories;
  }
}

// Domain Layer - Use Case für das Abrufen der Unterkategorien

import 'package:matzo/domain/entities/category.dart';
import 'package:matzo/domain/repositories/category_repository.dart';

class GetSubcategories {
  final CategoryRepository repository;

  GetSubcategories(this.repository);

  Future<List<Category>> call(int parentCategoryId) async {
    final categories = await repository.getSubcategories(parentCategoryId);
    // Sortierung erfolgt bereits im Repository
    return categories;
  }
}

// Domain Layer - Use Case für das Löschen einer Kategorie

import 'package:matzo/domain/repositories/category_repository.dart';

class DeleteCategory {
  final CategoryRepository repository;

  DeleteCategory(this.repository);

  Future<void> call(int categoryId) async {
    await repository.deleteCategory(categoryId);
  }
}

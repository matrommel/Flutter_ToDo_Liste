// Domain Layer - Use Case für Kategorie-Schutz aktualisieren

import 'package:matzo/domain/repositories/category_repository.dart';

class UpdateCategoryProtection {
  final CategoryRepository repository;

  UpdateCategoryProtection(this.repository);

  Future<void> call(int categoryId, bool isProtected) async {
    return repository.updateCategoryProtection(categoryId, isProtected);
  }
}

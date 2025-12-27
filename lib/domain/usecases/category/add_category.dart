// Domain Layer - Use Case für das Hinzufügen einer Kategorie

import 'package:matzo/domain/entities/category.dart';
import 'package:matzo/domain/repositories/category_repository.dart';

class AddCategory {
  final CategoryRepository repository;

  AddCategory(this.repository);

  Future<int> call(String name, {int? iconCodePoint, int? parentCategoryId}) async {
    // Validierung
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw Exception('Kategoriename darf nicht leer sein');
    }
    if (trimmedName.length > 50) {
      throw Exception('Kategoriename darf maximal 50 Zeichen lang sein');
    }

    final category = Category(
      name: trimmedName,
      createdAt: DateTime.now(),
      iconCodePoint: iconCodePoint,
      parentCategoryId: parentCategoryId,
    );

    return await repository.addCategory(category);
  }
}

// Domain Layer - Use Case für das Hinzufügen einer Kategorie

import 'package:matzo/domain/entities/category.dart';
import 'package:matzo/domain/repositories/category_repository.dart';

class AddCategory {
  final CategoryRepository repository;

  AddCategory(this.repository);

  Future<int> call(String name, {int? iconCodePoint}) async {
    // Validierung
    if (name.trim().isEmpty) {
      throw Exception('Kategoriename darf nicht leer sein');
    }
    if (name.length > 50) {
      throw Exception('Kategoriename darf maximal 50 Zeichen lang sein');
    }

    final category = Category(
      name: name.trim(),
      createdAt: DateTime.now(),
      iconCodePoint: iconCodePoint,
    );

    return await repository.addCategory(category);
  }
}

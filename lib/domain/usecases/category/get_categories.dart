// Domain Layer - Use Case für das Abrufen aller Kategorien

import 'package:matzo/domain/entities/category.dart';
import 'package:matzo/domain/repositories/category_repository.dart';

class GetCategories {
  final CategoryRepository repository;

  GetCategories(this.repository);

  Future<List<Category>> call() async {
    final categories = await repository.getAllCategories();
    // Sortierung nach order und dann nach Name
    categories.sort((a, b) {
      final orderCompare = a.order.compareTo(b.order);
      if (orderCompare != 0) return orderCompare;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return categories;
  }
}

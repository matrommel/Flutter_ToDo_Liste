import 'package:matzo/domain/entities/category.dart';
import 'package:matzo/domain/repositories/category_repository.dart';

class UpdateCategory {
  final CategoryRepository repository;

  UpdateCategory(this.repository);

  Future<void> call({
    required int categoryId,
    required String newName,
    int? newIconCodePoint,
  }) async {
    // Hole die aktuelle Kategorie
    final currentCategory = await repository.getCategoryById(categoryId);
    if (currentCategory == null) {
      throw Exception('Kategorie nicht gefunden');
    }

    // Erstelle aktualisierte Kategorie mit neuen Werten
    final updatedCategory = Category(
      id: currentCategory.id,
      name: newName,
      createdAt: currentCategory.createdAt,
      order: currentCategory.order,
      iconCodePoint: newIconCodePoint,
      isProtected: currentCategory.isProtected,
      parentCategoryId: currentCategory.parentCategoryId,
    );

    await repository.updateCategory(updatedCategory);
  }
}

import 'package:matzo/domain/entities/category.dart';
import 'package:matzo/domain/repositories/category_repository.dart';

class ReorderCategories {
  final CategoryRepository repository;

  ReorderCategories(this.repository);

  Future<void> call(List<Category> categories) async {
    for (int i = 0; i < categories.length; i++) {
      final updatedCategory = Category(
        id: categories[i].id,
        name: categories[i].name,
        createdAt: categories[i].createdAt,
        order: i,
        iconCodePoint: categories[i].iconCodePoint,
        isProtected: categories[i].isProtected,
        parentCategoryId: categories[i].parentCategoryId,
      );
      await repository.updateCategory(updatedCategory);
    }
  }
}

// Domain Layer - Use Case für das Zählen offener Items einer Kategorie

import 'package:matzo/domain/repositories/category_repository.dart';

class GetCategoryItemCount {
  final CategoryRepository repository;

  GetCategoryItemCount(this.repository);

  Future<int> call(int categoryId) async {
    return await repository.getCategoryItemCount(categoryId);
  }
}

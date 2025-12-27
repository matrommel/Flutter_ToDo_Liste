// Domain Layer - Use Case für Unterkategorie-Zählung

import 'package:matzo/domain/repositories/category_repository.dart';

class GetSubcategoryCount {
  final CategoryRepository repository;

  GetSubcategoryCount(this.repository);

  Future<int> call(int categoryId) async {
    return await repository.getSubcategoryCount(categoryId);
  }
}

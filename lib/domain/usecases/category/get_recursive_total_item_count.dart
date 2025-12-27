// Domain Layer - Use Case für rekursive Total Item-Zählung (inkl. completed)

import 'package:matzo/domain/repositories/category_repository.dart';

class GetRecursiveTotalItemCount {
  final CategoryRepository repository;

  GetRecursiveTotalItemCount(this.repository);

  Future<int> call(int categoryId) async {
    return await repository.getRecursiveTotalItemCount(categoryId);
  }
}

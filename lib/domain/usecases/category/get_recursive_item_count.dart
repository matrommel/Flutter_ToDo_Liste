// Domain Layer - Use Case für rekursive Item-Zählung

import 'package:matzo/domain/repositories/category_repository.dart';

class GetRecursiveItemCount {
  final CategoryRepository repository;

  GetRecursiveItemCount(this.repository);

  Future<int> call(int categoryId) async {
    return await repository.getRecursiveItemCount(categoryId);
  }
}

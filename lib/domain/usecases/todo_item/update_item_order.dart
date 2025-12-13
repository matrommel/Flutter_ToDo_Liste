// Domain Layer - Use Case für das Setzen der Item-Reihenfolge

import 'package:matzo/domain/repositories/todo_item_repository.dart';

class UpdateItemOrder {
  final TodoItemRepository repository;

  UpdateItemOrder(this.repository);

  Future<void> call(int itemId, int newOrder) async {
    await repository.updateItemOrder(itemId, newOrder);
  }
}

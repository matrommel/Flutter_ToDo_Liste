// Domain Layer - Use Case für das Abhaken/Aufheben eines Items

import 'package:matzo/domain/repositories/todo_item_repository.dart';

class ToggleTodoItem {
  final TodoItemRepository repository;

  ToggleTodoItem(this.repository);

  Future<void> call(int itemId) async {
    await repository.toggleItemCompletion(itemId);
  }
}

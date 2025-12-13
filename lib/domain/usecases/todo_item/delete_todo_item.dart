// Domain Layer - Use Case für das Löschen eines Todo-Items

import 'package:matzo/domain/repositories/todo_item_repository.dart';

class DeleteTodoItem {
  final TodoItemRepository repository;

  DeleteTodoItem(this.repository);

  Future<void> call(int itemId) async {
    await repository.deleteItem(itemId);
  }
}

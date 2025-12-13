import 'package:matzo/domain/entities/todo_item.dart';
import 'package:matzo/domain/repositories/todo_item_repository.dart';

class EditTodoItem {
  final TodoItemRepository repository;

  EditTodoItem(this.repository);

  Future<void> call({
    required TodoItem item,
    required String newTitle,
  }) async {
    if (newTitle.trim().isEmpty) {
      throw Exception('Item-Name darf nicht leer sein');
    }
    
    if (newTitle.length > 100) {
      throw Exception('Item-Name darf maximal 100 Zeichen lang sein');
    }

    final updatedItem = item.copyWith(title: newTitle.trim());
    await repository.updateItem(updatedItem);
  }
}

import 'package:matzo/domain/entities/todo_item.dart';
import 'package:matzo/domain/repositories/todo_item_repository.dart';

class UpdateTodoItem {
  final TodoItemRepository repository;

  UpdateTodoItem(this.repository);

  Future<void> call({
    required TodoItem item,
    String? newTitle,
    int? newCount,
    String? description,
    List<String>? links,
  }) async {
    if (newTitle != null) {
      if (newTitle.trim().isEmpty) {
        throw Exception('Item-Name darf nicht leer sein');
      }
      if (newTitle.length > 100) {
        throw Exception('Item-Name darf maximal 100 Zeichen lang sein');
      }
    }

    if (newCount != null && newCount < 1) {
      throw Exception('Anzahl muss mindestens 1 sein');
    }

    final updatedItem = item.copyWith(
      title: newTitle?.trim(),
      count: newCount,
      description: description,
      links: links,
    );

    await repository.updateItem(updatedItem);
  }
}

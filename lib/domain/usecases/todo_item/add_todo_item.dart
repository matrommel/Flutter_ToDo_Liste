// Domain Layer - Use Case für das Hinzufügen eines Todo-Items

import 'package:matzo/domain/entities/todo_item.dart';
import 'package:matzo/domain/repositories/todo_item_repository.dart';

class AddTodoItem {
  final TodoItemRepository repository;

  AddTodoItem(this.repository);

  Future<int> call({
    required int categoryId,
    required String title,
    int count = 1,
    int order = 0,
    String? description,
  }) async {
    // Validierung
    if (title.trim().isEmpty) {
      throw Exception('Item-Name darf nicht leer sein');
    }
    if (title.length > 100) {
      throw Exception('Item-Name darf maximal 100 Zeichen lang sein');
    }
    if (count < 1) {
      throw Exception('Anzahl muss mindestens 1 sein');
    }

    final item = TodoItem(
      categoryId: categoryId,
      title: title.trim(),
      count: count,
      order: order,
      createdAt: DateTime.now(),
      description: description,
    );

    return await repository.addItem(item);
  }
}

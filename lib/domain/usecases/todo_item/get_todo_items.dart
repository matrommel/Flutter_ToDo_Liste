// Domain Layer - Use Case für das Abrufen aller Items einer Kategorie

import 'package:matzo/domain/entities/todo_item.dart';
import 'package:matzo/domain/repositories/todo_item_repository.dart';

class GetTodoItems {
  final TodoItemRepository repository;

  GetTodoItems(this.repository);

  Future<List<TodoItem>> call(int categoryId) async {
    final items = await repository.getItemsByCategory(categoryId);
    
    // Sortieren: Zuerst offene Items (alphabetisch), dann erledigte Items
    items.sort((a, b) {
      // Erst nach Status (nicht erledigt zuerst)
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      // Dann alphabetisch nach Titel
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });
    
    return items;
  }
}

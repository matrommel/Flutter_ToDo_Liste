import 'package:matzo/domain/entities/category.dart';
import 'package:matzo/domain/entities/todo_item.dart';
import 'package:matzo/domain/repositories/category_repository.dart';
import 'package:matzo/domain/repositories/todo_item_repository.dart';

class SearchResult {
  final TodoItem item;
  final Category category;

  SearchResult({required this.item, required this.category});
}

class SearchTodoItems {
  final CategoryRepository categoryRepository;
  final TodoItemRepository todoItemRepository;

  SearchTodoItems({
    required this.categoryRepository,
    required this.todoItemRepository,
  });

  Future<List<SearchResult>> call(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    final searchQuery = query.toLowerCase().trim();
    final categories = await categoryRepository.getAllCategories();
    final List<SearchResult> results = [];

    for (final category in categories) {
      if (category.id != null) {
        final items = await todoItemRepository.getItemsByCategory(category.id!);
        
        for (final item in items) {
          if (item.title.toLowerCase().contains(searchQuery) ||
              category.name.toLowerCase().contains(searchQuery)) {
            results.add(SearchResult(item: item, category: category));
          }
        }
      }
    }

    return results;
  }
}

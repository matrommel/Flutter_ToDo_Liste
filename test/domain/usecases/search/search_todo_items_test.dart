import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:matzo/domain/entities/category.dart';
import 'package:matzo/domain/entities/todo_item.dart';
import 'package:matzo/domain/repositories/category_repository.dart';
import 'package:matzo/domain/repositories/todo_item_repository.dart';
import 'package:matzo/domain/usecases/search/search_todo_items.dart';

import 'search_todo_items_test.mocks.dart';

@GenerateMocks([CategoryRepository, TodoItemRepository])
void main() {
  late SearchTodoItems useCase;
  late MockCategoryRepository mockCategoryRepository;
  late MockTodoItemRepository mockTodoItemRepository;

  setUp(() {
    mockCategoryRepository = MockCategoryRepository();
    mockTodoItemRepository = MockTodoItemRepository();
    useCase = SearchTodoItems(
      categoryRepository: mockCategoryRepository,
      todoItemRepository: mockTodoItemRepository,
    );
  });

  group('SearchTodoItems UseCase', () {
    late List<Category> testCategories;
    late Map<int, List<TodoItem>> testItems;

    setUp(() {
      testCategories = [
        Category(
          id: 1,
          name: 'Einkaufen',
          createdAt: DateTime.now(),
        ),
        Category(
          id: 2,
          name: 'Arbeit',
          createdAt: DateTime.now(),
        ),
      ];

      testItems = {
        1: [
          TodoItem(
            id: 1,
            categoryId: 1,
            title: 'Milch kaufen',
            isCompleted: false,
            createdAt: DateTime.now(),
          ),
          TodoItem(
            id: 2,
            categoryId: 1,
            title: 'Brot kaufen',
            isCompleted: false,
            createdAt: DateTime.now(),
          ),
        ],
        2: [
          TodoItem(
            id: 3,
            categoryId: 2,
            title: 'Präsentation vorbereiten',
            isCompleted: false,
            createdAt: DateTime.now(),
          ),
        ],
      };
    });

    test('sollte Items nach Titel finden', () async {
      // Arrange
      when(mockCategoryRepository.getCategories())
          .thenAnswer((_) async => testCategories);
      when(mockTodoItemRepository.getTodoItemsByCategoryId(1))
          .thenAnswer((_) async => testItems[1]!);
      when(mockTodoItemRepository.getTodoItemsByCategoryId(2))
          .thenAnswer((_) async => testItems[2]!);

      // Act
      final result = await useCase('milch');

      // Assert
      expect(result.length, 1);
      expect(result[0].item.title, 'Milch kaufen');
      expect(result[0].category.name, 'Einkaufen');
    });

    test('sollte Items nach Kategorie-Namen finden', () async {
      // Arrange
      when(mockCategoryRepository.getCategories())
          .thenAnswer((_) async => testCategories);
      when(mockTodoItemRepository.getTodoItemsByCategoryId(1))
          .thenAnswer((_) async => testItems[1]!);
      when(mockTodoItemRepository.getTodoItemsByCategoryId(2))
          .thenAnswer((_) async => testItems[2]!);

      // Act
      final result = await useCase('einkaufen');

      // Assert
      expect(result.length, 2); // Beide Items aus "Einkaufen"
      expect(result.every((r) => r.category.name == 'Einkaufen'), true);
    });

    test('sollte Groß-/Kleinschreibung ignorieren', () async {
      // Arrange
      when(mockCategoryRepository.getCategories())
          .thenAnswer((_) async => testCategories);
      when(mockTodoItemRepository.getTodoItemsByCategoryId(1))
          .thenAnswer((_) async => testItems[1]!);
      when(mockTodoItemRepository.getTodoItemsByCategoryId(2))
          .thenAnswer((_) async => testItems[2]!);

      // Act
      final result = await useCase('MILCH');

      // Assert
      expect(result.length, 1);
      expect(result[0].item.title, 'Milch kaufen');
    });

    test('sollte Teilstrings finden', () async {
      // Arrange
      when(mockCategoryRepository.getCategories())
          .thenAnswer((_) async => testCategories);
      when(mockTodoItemRepository.getTodoItemsByCategoryId(1))
          .thenAnswer((_) async => testItems[1]!);
      when(mockTodoItemRepository.getTodoItemsByCategoryId(2))
          .thenAnswer((_) async => testItems[2]!);

      // Act
      final result = await useCase('kaufen');

      // Assert
      expect(result.length, 2); // Milch und Brot kaufen
    });

    test('sollte leere Liste zurückgeben bei leerem Query', () async {
      // Act
      final result = await useCase('');

      // Assert
      expect(result, isEmpty);
      verifyNever(mockCategoryRepository.getCategories());
    });

    test('sollte leere Liste zurückgeben bei nur Whitespace', () async {
      // Act
      final result = await useCase('   ');

      // Assert
      expect(result, isEmpty);
      verifyNever(mockCategoryRepository.getCategories());
    });

    test('sollte Whitespace trimmen', () async {
      // Arrange
      when(mockCategoryRepository.getCategories())
          .thenAnswer((_) async => testCategories);
      when(mockTodoItemRepository.getTodoItemsByCategoryId(1))
          .thenAnswer((_) async => testItems[1]!);
      when(mockTodoItemRepository.getTodoItemsByCategoryId(2))
          .thenAnswer((_) async => testItems[2]!);

      // Act
      final result = await useCase('  milch  ');

      // Assert
      expect(result.length, 1);
      expect(result[0].item.title, 'Milch kaufen');
    });

    test('sollte leere Liste zurückgeben wenn keine Treffer', () async {
      // Arrange
      when(mockCategoryRepository.getCategories())
          .thenAnswer((_) async => testCategories);
      when(mockTodoItemRepository.getTodoItemsByCategoryId(1))
          .thenAnswer((_) async => testItems[1]!);
      when(mockTodoItemRepository.getTodoItemsByCategoryId(2))
          .thenAnswer((_) async => testItems[2]!);

      // Act
      final result = await useCase('nonexistent');

      // Assert
      expect(result, isEmpty);
    });

    test('sollte alle passenden Items über mehrere Kategorien finden', () async {
      // Arrange
      testItems[2] = [
        ...testItems[2]!,
        TodoItem(
          id: 4,
          categoryId: 2,
          title: 'Milch für Meeting besorgen',
          isCompleted: false,
          createdAt: DateTime.now(),
        ),
      ];

      when(mockCategoryRepository.getCategories())
          .thenAnswer((_) async => testCategories);
      when(mockTodoItemRepository.getTodoItemsByCategoryId(1))
          .thenAnswer((_) async => testItems[1]!);
      when(mockTodoItemRepository.getTodoItemsByCategoryId(2))
          .thenAnswer((_) async => testItems[2]!);

      // Act
      final result = await useCase('milch');

      // Assert
      expect(result.length, 2); // Eines aus Einkaufen, eines aus Arbeit
      expect(result.any((r) => r.category.name == 'Einkaufen'), true);
      expect(result.any((r) => r.category.name == 'Arbeit'), true);
    });

    test('sollte auch erledigte Items finden', () async {
      // Arrange
      testItems[1] = [
        TodoItem(
          id: 1,
          categoryId: 1,
          title: 'Milch kaufen',
          isCompleted: true,
          createdAt: DateTime.now(),
        ),
      ];

      when(mockCategoryRepository.getCategories())
          .thenAnswer((_) async => testCategories);
      when(mockTodoItemRepository.getTodoItemsByCategoryId(1))
          .thenAnswer((_) async => testItems[1]!);
      when(mockTodoItemRepository.getTodoItemsByCategoryId(2))
          .thenAnswer((_) async => []);

      // Act
      final result = await useCase('milch');

      // Assert
      expect(result.length, 1);
      expect(result[0].item.isCompleted, true);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:matzo/domain/entities/todo_item.dart';
import 'package:matzo/domain/repositories/todo_item_repository.dart';
import 'package:matzo/domain/usecases/todo_item/get_todo_items.dart';

import 'get_todo_items_test.mocks.dart';

@GenerateMocks([TodoItemRepository])
void main() {
  late GetTodoItems useCase;
  late MockTodoItemRepository mockRepository;

  setUp(() {
    mockRepository = MockTodoItemRepository();
    useCase = GetTodoItems(mockRepository);
  });

  group('GetTodoItems UseCase', () {
    const testCategoryId = 1;

    test('sollte Items für Kategorie abrufen', () async {
      // Arrange
      final items = [
        TodoItem(
          id: 1,
          categoryId: testCategoryId,
          title: 'Item 1',
          order: 0,
          isCompleted: false,
          createdAt: DateTime.now(),
        ),
      ];

        when(mockRepository.getItemsByCategory(testCategoryId))
          .thenAnswer((_) async => items);

      // Act
      final result = await useCase(testCategoryId);

      // Assert
      expect(result, items);
      verify(mockRepository.getItemsByCategory(testCategoryId)).called(1);
    });

    test('sollte offene Items nach manueller Reihenfolge (order) sortieren', () async {
      // Arrange
      final items = [
        TodoItem(
          id: 3,
          categoryId: testCategoryId,
          title: 'Zucchini',
          order: 2,
          isCompleted: false,
          createdAt: DateTime.now(),
        ),
        TodoItem(
          id: 1,
          categoryId: testCategoryId,
          title: 'Apfel',
          order: 0,
          isCompleted: false,
          createdAt: DateTime.now(),
        ),
        TodoItem(
          id: 2,
          categoryId: testCategoryId,
          title: 'Milch',
          order: 1,
          isCompleted: false,
          createdAt: DateTime.now(),
        ),
      ];

        when(mockRepository.getItemsByCategory(testCategoryId))
          .thenAnswer((_) async => items);

      // Act
      final result = await useCase(testCategoryId);

      // Assert
      expect(result.length, 3);
      expect(result[0].title, 'Apfel');  // order: 0
      expect(result[1].title, 'Milch');   // order: 1
      expect(result[2].title, 'Zucchini'); // order: 2
    });

    test('sollte erledigte Items nach manueller Reihenfolge (order) sortieren', () async {
      // Arrange
      final items = [
        TodoItem(
          id: 3,
          categoryId: testCategoryId,
          title: 'Zwiebeln',
          order: 1,
          isCompleted: true,
          createdAt: DateTime.now(),
        ),
        TodoItem(
          id: 1,
          categoryId: testCategoryId,
          title: 'Butter',
          order: 0,
          isCompleted: true,
          createdAt: DateTime.now(),
        ),
      ];

        when(mockRepository.getItemsByCategory(testCategoryId))
          .thenAnswer((_) async => items);

      // Act
      final result = await useCase(testCategoryId);

      // Assert
      expect(result.length, 2);
      expect(result[0].title, 'Butter');    // order: 0
      expect(result[1].title, 'Zwiebeln');  // order: 1
    });

    test('sollte offene Items vor erledigten Items platzieren', () async {
      // Arrange
      final items = [
        TodoItem(
          id: 1,
          categoryId: testCategoryId,
          title: 'Erledigtes Item',
          order: 1,
          isCompleted: true,
          createdAt: DateTime.now(),
        ),
        TodoItem(
          id: 2,
          categoryId: testCategoryId,
          title: 'Offenes Item',
          order: 0,
          isCompleted: false,
          createdAt: DateTime.now(),
        ),
      ];

        when(mockRepository.getItemsByCategory(testCategoryId))
          .thenAnswer((_) async => items);

      // Act
      final result = await useCase(testCategoryId);

      // Assert
      expect(result.length, 2);
      expect(result[0].title, 'Offenes Item');
      expect(result[0].isCompleted, false);
      expect(result[1].title, 'Erledigtes Item');
      expect(result[1].isCompleted, true);
    });

    test('sollte nach manueller Reihenfolge sortieren (unabhängig von Groß-/Kleinschreibung)', () async {
      // Arrange
      final items = [
        TodoItem(
          id: 1,
          categoryId: testCategoryId,
          title: 'ZEBRA',
          order: 2,
          isCompleted: false,
          createdAt: DateTime.now(),
        ),
        TodoItem(
          id: 2,
          categoryId: testCategoryId,
          title: 'apfel',
          order: 0,
          isCompleted: false,
          createdAt: DateTime.now(),
        ),
        TodoItem(
          id: 3,
          categoryId: testCategoryId,
          title: 'Milch',
          order: 1,
          isCompleted: false,
          createdAt: DateTime.now(),
        ),
      ];

        when(mockRepository.getItemsByCategory(testCategoryId))
          .thenAnswer((_) async => items);

      // Act
      final result = await useCase(testCategoryId);

      // Assert
      expect(result[0].title, 'apfel');  // order: 0
      expect(result[1].title, 'Milch');  // order: 1
      expect(result[2].title, 'ZEBRA');  // order: 2
    });

    test('sollte leere Liste zurückgeben wenn keine Items', () async {
      // Arrange
        when(mockRepository.getItemsByCategory(testCategoryId))
          .thenAnswer((_) async => []);

      // Act
      final result = await useCase(testCategoryId);

      // Assert
      expect(result, isEmpty);
    });

    test('sollte gemischte offene und erledigte Items nach manueller Reihenfolge sortieren', () async {
      // Arrange
      final items = [
        TodoItem(
          id: 1,
          categoryId: testCategoryId,
          title: 'Z Erledigt',
          order: 3,
          isCompleted: true,
          createdAt: DateTime.now(),
        ),
        TodoItem(
          id: 2,
          categoryId: testCategoryId,
          title: 'B Offen',
          order: 0,
          isCompleted: false,
          createdAt: DateTime.now(),
        ),
        TodoItem(
          id: 3,
          categoryId: testCategoryId,
          title: 'A Erledigt',
          order: 2,
          isCompleted: true,
          createdAt: DateTime.now(),
        ),
        TodoItem(
          id: 4,
          categoryId: testCategoryId,
          title: 'C Offen',
          order: 1,
          isCompleted: false,
          createdAt: DateTime.now(),
        ),
      ];

        when(mockRepository.getItemsByCategory(testCategoryId))
          .thenAnswer((_) async => items);

      // Act
      final result = await useCase(testCategoryId);

      // Assert
      expect(result.length, 4);
      // Offene Items zuerst, nach order-Feld
      expect(result[0].title, 'B Offen');      // order: 0
      expect(result[0].isCompleted, false);
      expect(result[1].title, 'C Offen');      // order: 1
      expect(result[1].isCompleted, false);
      // Dann erledigte Items, nach order-Feld
      expect(result[2].title, 'A Erledigt');   // order: 2
      expect(result[2].isCompleted, true);
      expect(result[3].title, 'Z Erledigt');   // order: 3
      expect(result[3].isCompleted, true);
    });
  });
}

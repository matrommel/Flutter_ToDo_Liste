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
          isCompleted: false,
          createdAt: DateTime.now(),
        ),
      ];

      when(mockRepository.getTodoItemsByCategoryId(testCategoryId))
          .thenAnswer((_) async => items);

      // Act
      final result = await useCase(testCategoryId);

      // Assert
      expect(result, items);
      verify(mockRepository.getTodoItemsByCategoryId(testCategoryId)).called(1);
    });

    test('sollte offene Items alphabetisch sortieren', () async {
      // Arrange
      final items = [
        TodoItem(
          id: 3,
          categoryId: testCategoryId,
          title: 'Zucchini',
          isCompleted: false,
          createdAt: DateTime.now(),
        ),
        TodoItem(
          id: 1,
          categoryId: testCategoryId,
          title: 'Äpfel',
          isCompleted: false,
          createdAt: DateTime.now(),
        ),
        TodoItem(
          id: 2,
          categoryId: testCategoryId,
          title: 'Milch',
          isCompleted: false,
          createdAt: DateTime.now(),
        ),
      ];

      when(mockRepository.getTodoItemsByCategoryId(testCategoryId))
          .thenAnswer((_) async => items);

      // Act
      final result = await useCase(testCategoryId);

      // Assert
      expect(result.length, 3);
      expect(result[0].title, 'Äpfel');
      expect(result[1].title, 'Milch');
      expect(result[2].title, 'Zucchini');
    });

    test('sollte erledigte Items alphabetisch sortieren', () async {
      // Arrange
      final items = [
        TodoItem(
          id: 3,
          categoryId: testCategoryId,
          title: 'Zwiebeln',
          isCompleted: true,
          createdAt: DateTime.now(),
        ),
        TodoItem(
          id: 1,
          categoryId: testCategoryId,
          title: 'Butter',
          isCompleted: true,
          createdAt: DateTime.now(),
        ),
      ];

      when(mockRepository.getTodoItemsByCategoryId(testCategoryId))
          .thenAnswer((_) async => items);

      // Act
      final result = await useCase(testCategoryId);

      // Assert
      expect(result.length, 2);
      expect(result[0].title, 'Butter');
      expect(result[1].title, 'Zwiebeln');
    });

    test('sollte offene Items vor erledigten Items platzieren', () async {
      // Arrange
      final items = [
        TodoItem(
          id: 1,
          categoryId: testCategoryId,
          title: 'Erledigtes Item',
          isCompleted: true,
          createdAt: DateTime.now(),
        ),
        TodoItem(
          id: 2,
          categoryId: testCategoryId,
          title: 'Offenes Item',
          isCompleted: false,
          createdAt: DateTime.now(),
        ),
      ];

      when(mockRepository.getTodoItemsByCategoryId(testCategoryId))
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

    test('sollte Groß-/Kleinschreibung bei Sortierung ignorieren', () async {
      // Arrange
      final items = [
        TodoItem(
          id: 1,
          categoryId: testCategoryId,
          title: 'ZEBRA',
          isCompleted: false,
          createdAt: DateTime.now(),
        ),
        TodoItem(
          id: 2,
          categoryId: testCategoryId,
          title: 'apfel',
          isCompleted: false,
          createdAt: DateTime.now(),
        ),
        TodoItem(
          id: 3,
          categoryId: testCategoryId,
          title: 'Milch',
          isCompleted: false,
          createdAt: DateTime.now(),
        ),
      ];

      when(mockRepository.getTodoItemsByCategoryId(testCategoryId))
          .thenAnswer((_) async => items);

      // Act
      final result = await useCase(testCategoryId);

      // Assert
      expect(result[0].title, 'apfel');
      expect(result[1].title, 'Milch');
      expect(result[2].title, 'ZEBRA');
    });

    test('sollte leere Liste zurückgeben wenn keine Items', () async {
      // Arrange
      when(mockRepository.getTodoItemsByCategoryId(testCategoryId))
          .thenAnswer((_) async => []);

      // Act
      final result = await useCase(testCategoryId);

      // Assert
      expect(result, isEmpty);
    });

    test('sollte gemischte offene und erledigte Items korrekt sortieren', () async {
      // Arrange
      final items = [
        TodoItem(
          id: 1,
          categoryId: testCategoryId,
          title: 'Z Erledigt',
          isCompleted: true,
          createdAt: DateTime.now(),
        ),
        TodoItem(
          id: 2,
          categoryId: testCategoryId,
          title: 'B Offen',
          isCompleted: false,
          createdAt: DateTime.now(),
        ),
        TodoItem(
          id: 3,
          categoryId: testCategoryId,
          title: 'A Erledigt',
          isCompleted: true,
          createdAt: DateTime.now(),
        ),
        TodoItem(
          id: 4,
          categoryId: testCategoryId,
          title: 'C Offen',
          isCompleted: false,
          createdAt: DateTime.now(),
        ),
      ];

      when(mockRepository.getTodoItemsByCategoryId(testCategoryId))
          .thenAnswer((_) async => items);

      // Act
      final result = await useCase(testCategoryId);

      // Assert
      expect(result.length, 4);
      // Offene Items zuerst, alphabetisch
      expect(result[0].title, 'B Offen');
      expect(result[0].isCompleted, false);
      expect(result[1].title, 'C Offen');
      expect(result[1].isCompleted, false);
      // Dann erledigte Items, alphabetisch
      expect(result[2].title, 'A Erledigt');
      expect(result[2].isCompleted, true);
      expect(result[3].title, 'Z Erledigt');
      expect(result[3].isCompleted, true);
    });
  });
}

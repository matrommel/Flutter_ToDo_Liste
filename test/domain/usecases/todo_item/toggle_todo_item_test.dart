import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:matzo/domain/entities/todo_item.dart';
import 'package:matzo/domain/repositories/todo_item_repository.dart';
import 'package:matzo/domain/usecases/todo_item/toggle_todo_item.dart';

import 'toggle_todo_item_test.mocks.dart';

@GenerateMocks([TodoItemRepository])
void main() {
  late ToggleTodoItem useCase;
  late MockTodoItemRepository mockRepository;

  setUp(() {
    mockRepository = MockTodoItemRepository();
    useCase = ToggleTodoItem(mockRepository);
  });

  group('ToggleTodoItem UseCase', () {
    test('sollte nicht-erledigtes Item als erledigt markieren', () async {
      // Arrange
      final openItem = TodoItem(
        id: 1,
        categoryId: 1,
        title: 'Test Item',
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      when(mockRepository.updateTodoItem(any))
          .thenAnswer((_) async => {});

      // Act
      await useCase(openItem);

      // Assert
      verify(mockRepository.updateTodoItem(
        argThat(predicate<TodoItem>(
          (item) =>
              item.id == 1 &&
              item.isCompleted == true &&
              item.completedAt != null,
        )),
      )).called(1);
    });

    test('sollte erledigtes Item als nicht-erledigt markieren', () async {
      // Arrange
      final completedItem = TodoItem(
        id: 1,
        categoryId: 1,
        title: 'Test Item',
        isCompleted: true,
        completedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      when(mockRepository.updateTodoItem(any))
          .thenAnswer((_) async => {});

      // Act
      await useCase(completedItem);

      // Assert
      verify(mockRepository.updateTodoItem(
        argThat(predicate<TodoItem>(
          (item) =>
              item.id == 1 &&
              item.isCompleted == false &&
              item.completedAt == null,
        )),
      )).called(1);
    });

    test('sollte completedAt setzen beim Erledigen', () async {
      // Arrange
      final openItem = TodoItem(
        id: 1,
        categoryId: 1,
        title: 'Test Item',
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      when(mockRepository.updateTodoItem(any))
          .thenAnswer((_) async => {});

      final beforeToggle = DateTime.now();

      // Act
      await useCase(openItem);

      // Assert
      final captured = verify(mockRepository.updateTodoItem(captureAny))
          .captured
          .first as TodoItem;
      
      expect(captured.completedAt, isNotNull);
      expect(
        captured.completedAt!.isAfter(beforeToggle.subtract(const Duration(seconds: 1))),
        true,
      );
    });

    test('sollte andere Felder unverändert lassen', () async {
      // Arrange
      final testItem = TodoItem(
        id: 1,
        categoryId: 5,
        title: 'Wichtiges Item',
        count: 3,
        isCompleted: false,
        createdAt: DateTime(2024, 1, 1),
      );

      when(mockRepository.updateTodoItem(any))
          .thenAnswer((_) async => {});

      // Act
      await useCase(testItem);

      // Assert
      verify(mockRepository.updateTodoItem(
        argThat(predicate<TodoItem>(
          (item) =>
              item.id == 1 &&
              item.categoryId == 5 &&
              item.title == 'Wichtiges Item' &&
              item.count == 3,
        )),
      )).called(1);
    });
  });
}

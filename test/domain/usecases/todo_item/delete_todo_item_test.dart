import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:matzo/domain/repositories/todo_item_repository.dart';
import 'package:matzo/domain/usecases/todo_item/delete_todo_item.dart';

import 'delete_todo_item_test.mocks.dart';

@GenerateMocks([TodoItemRepository])
void main() {
  late DeleteTodoItem useCase;
  late MockTodoItemRepository mockRepository;

  setUp(() {
    mockRepository = MockTodoItemRepository();
    useCase = DeleteTodoItem(mockRepository);
  });

  group('DeleteTodoItem UseCase', () {
    const testItemId = 1;

    test('sollte TodoItem erfolgreich löschen', () async {
      // Arrange
      when(mockRepository.deleteTodoItem(testItemId))
          .thenAnswer((_) async => Future.value());

      // Act
      await useCase(testItemId);

      // Assert
      verify(mockRepository.deleteTodoItem(testItemId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('sollte Exception weitergeben bei Fehler', () async {
      // Arrange
      when(mockRepository.deleteTodoItem(testItemId))
          .thenThrow(Exception('Database error'));

      // Act & Assert
      expect(
        () => useCase(testItemId),
        throwsA(isA<Exception>()),
      );
      verify(mockRepository.deleteTodoItem(testItemId)).called(1);
    });

    test('sollte mit verschiedenen IDs funktionieren', () async {
      // Arrange
      const ids = [1, 5, 100, 999];
      when(mockRepository.deleteTodoItem(any))
          .thenAnswer((_) async => Future.value());

      // Act & Assert
      for (final id in ids) {
        await useCase(id);
        verify(mockRepository.deleteTodoItem(id)).called(1);
      }
    });
  });
}

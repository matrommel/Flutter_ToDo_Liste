import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
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
    test('ruft toggleItemCompletion mit Item-ID auf', () async {
      // Arrange
      when(mockRepository.toggleItemCompletion(1)).thenAnswer((_) async => {});

      // Act
      await useCase(1);

      // Assert
      verify(mockRepository.toggleItemCompletion(1)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('gibt Repository-Fehler weiter', () async {
      when(mockRepository.toggleItemCompletion(42))
          .thenThrow(Exception('db error'));

      expect(() => useCase(42), throwsA(isA<Exception>()));
      verify(mockRepository.toggleItemCompletion(42)).called(1);
    });
  });
}

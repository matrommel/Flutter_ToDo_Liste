import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:matzo/domain/entities/todo_item.dart';
import 'package:matzo/domain/repositories/todo_item_repository.dart';
import 'package:matzo/domain/usecases/todo_item/update_todo_item.dart';

import 'update_todo_item_test.mocks.dart';

@GenerateMocks([TodoItemRepository])
void main() {
  late UpdateTodoItem useCase;
  late MockTodoItemRepository mockRepository;

  setUp(() {
    mockRepository = MockTodoItemRepository();
    useCase = UpdateTodoItem(mockRepository);
  });

  group('UpdateTodoItem UseCase', () {
    final testItem = TodoItem(
      id: 1,
      categoryId: 1,
      title: 'Milch',
      count: 2,
      createdAt: DateTime(2024, 1, 1),
    );

    test('sollte Titel erfolgreich aktualisieren', () async {
      // Arrange
      const newTitle = 'Milch (Bio)';
      when(mockRepository.updateItem(any)).thenAnswer((_) async => Future.value());

      // Act
      await useCase(item: testItem, newTitle: newTitle, newCount: testItem.count);

      // Assert
      final captured = verify(mockRepository.updateItem(captureAny)).captured;
      final updatedItem = captured.first as TodoItem;
      expect(updatedItem.title, newTitle);
      expect(updatedItem.count, testItem.count); // Count unverändert
      verifyNoMoreInteractions(mockRepository);
    });

    test('sollte Count erfolgreich aktualisieren', () async {
      // Arrange
      const newCount = 5;
      when(mockRepository.updateItem(any)).thenAnswer((_) async => Future.value());

      // Act
      await useCase(item: testItem, newTitle: testItem.title, newCount: newCount);

      // Assert
      final captured = verify(mockRepository.updateItem(captureAny)).captured;
      final updatedItem = captured.first as TodoItem;
      expect(updatedItem.count, newCount);
      expect(updatedItem.title, testItem.title); // Titel unverändert
    });

    test('sollte Titel und Count gleichzeitig aktualisieren', () async {
      // Arrange
      const newTitle = 'Vollmilch';
      const newCount = 3;
      when(mockRepository.updateItem(any)).thenAnswer((_) async => Future.value());

      // Act
      await useCase(item: testItem, newTitle: newTitle, newCount: newCount);

      // Assert
      final captured = verify(mockRepository.updateItem(captureAny)).captured;
      final updatedItem = captured.first as TodoItem;
      expect(updatedItem.title, newTitle);
      expect(updatedItem.count, newCount);
    });

    test('sollte Whitespace im Titel trimmen', () async {
      // Arrange
      const newTitle = '  Milch  ';
      when(mockRepository.updateItem(any)).thenAnswer((_) async => Future.value());

      // Act
      await useCase(item: testItem, newTitle: newTitle, newCount: testItem.count);

      // Assert
      final captured = verify(mockRepository.updateItem(captureAny)).captured;
      final updatedItem = captured.first as TodoItem;
      expect(updatedItem.title, 'Milch');
    });

    test('sollte Exception werfen bei leerem Titel', () async {
      // Act & Assert
      expect(
        () => useCase(item: testItem, newTitle: '', newCount: testItem.count),
          throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('darf nicht leer sein'),
          ),
        ),
      );
        verifyNever(mockRepository.updateItem(any));
    });

    test('sollte Exception werfen bei nur Whitespace im Titel', () async {
      // Act & Assert
      expect(
        () => useCase(item: testItem, newTitle: '   ', newCount: testItem.count),
          throwsA(isA<Exception>()),
      );
        verifyNever(mockRepository.updateItem(any));
    });

    test('sollte Exception werfen bei zu langem Titel (>100 Zeichen)', () async {
      // Arrange
      final longTitle = 'a' * 101;

      // Act & Assert
      expect(
        () => useCase(item: testItem, newTitle: longTitle),
          throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('maximal 100 Zeichen'),
          ),
        ),
      );
        verifyNever(mockRepository.updateItem(any));
    });

    test('sollte Exception werfen bei Count < 1', () async {
      // Act & Assert
      expect(
        () => useCase(item: testItem, newCount: 0),
          throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('mindestens 1'),
          ),
        ),
      );
        verifyNever(mockRepository.updateItem(any));
    });

    test('sollte Exception werfen bei negativem Count', () async {
      // Act & Assert
      expect(
        () => useCase(item: testItem, newCount: -5),
          throwsA(isA<Exception>()),
      );
        verifyNever(mockRepository.updateItem(any));
    });

    test('sollte Titel mit genau 100 Zeichen akzeptieren', () async {
      // Arrange
      final maxLengthTitle = 'a' * 100;
      when(mockRepository.updateItem(any)).thenAnswer((_) async => Future.value());

      // Act
      await useCase(item: testItem, newTitle: maxLengthTitle);

      // Assert
      verify(mockRepository.updateItem(any)).called(1);
    });

    test('sollte Count = 1 akzeptieren', () async {
      // Arrange
      when(mockRepository.updateItem(any)).thenAnswer((_) async => Future.value());

      // Act
      await useCase(item: testItem, newCount: 1);

      // Assert
      final captured = verify(mockRepository.updateItem(captureAny)).captured;
      final updatedItem = captured.first as TodoItem;
      expect(updatedItem.count, 1);
    });

    test('sollte nichts aktualisieren wenn keine Parameter übergeben werden', () async {
      // Arrange
      when(mockRepository.updateItem(any)).thenAnswer((_) async => Future.value());

      // Act
      await useCase(item: testItem);

      // Assert
      final captured = verify(mockRepository.updateItem(captureAny)).captured;
      final updatedItem = captured.first as TodoItem;
      expect(updatedItem.title, testItem.title);
      expect(updatedItem.count, testItem.count);
    });
  });
}

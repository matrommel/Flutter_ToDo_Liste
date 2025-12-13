import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:matzo/domain/entities/todo_item.dart';
import 'package:matzo/domain/repositories/todo_item_repository.dart';
import 'package:matzo/domain/usecases/todo_item/edit_todo_item.dart';

import 'edit_todo_item_test.mocks.dart';

@GenerateMocks([TodoItemRepository])
void main() {
  late EditTodoItem useCase;
  late MockTodoItemRepository mockRepository;

  setUp(() {
    mockRepository = MockTodoItemRepository();
    useCase = EditTodoItem(mockRepository);
  });

  group('EditTodoItem UseCase', () {
    late TodoItem testItem;

    setUp(() {
      testItem = TodoItem(
        id: 1,
        categoryId: 1,
        title: 'Alter Titel',
        count: 2,
        isCompleted: false,
        createdAt: DateTime.now(),
      );
    });

    test('sollte Item-Titel erfolgreich aktualisieren', () async {
      // Arrange
      const newTitle = 'Neuer Titel';
        when(mockRepository.updateItem(any)).thenAnswer((_) async => {});

      // Act
      await useCase(item: testItem, newTitle: newTitle);

      // Assert
      verify(mockRepository.updateItem(
        argThat(predicate<TodoItem>(
          (item) => item.id == 1 && item.title == newTitle,
        )),
      )).called(1);
    });

    test('sollte Whitespace trimmen', () async {
      // Arrange
      const titleWithSpaces = '  Neuer Titel  ';
        when(mockRepository.updateItem(any)).thenAnswer((_) async => {});

      // Act
      await useCase(item: testItem, newTitle: titleWithSpaces);

      // Assert
      verify(mockRepository.updateItem(
        argThat(predicate<TodoItem>((item) => item.title == 'Neuer Titel')),
      )).called(1);
    });

    test('sollte Exception werfen bei leerem Titel', () async {
      // Act & Assert
      expect(
        () => useCase(item: testItem, newTitle: ''),
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

    test('sollte Exception werfen bei nur Whitespace', () async {
      // Act & Assert
      expect(
        () => useCase(item: testItem, newTitle: '   '),
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

    test('sollte Titel mit genau 100 Zeichen akzeptieren', () async {
      // Arrange
      final maxLengthTitle = 'a' * 100;
        when(mockRepository.updateItem(any)).thenAnswer((_) async => {});

      // Act
      await useCase(item: testItem, newTitle: maxLengthTitle);

      // Assert
      verify(mockRepository.updateItem(any)).called(1);
    });

    test('sollte andere Felder unverändert lassen', () async {
      // Arrange
      const newTitle = 'Neuer Titel';
        when(mockRepository.updateItem(any)).thenAnswer((_) async => {});

      // Act
      await useCase(item: testItem, newTitle: newTitle);

      // Assert
      verify(mockRepository.updateItem(
        argThat(predicate<TodoItem>(
          (item) =>
              item.id == 1 &&
              item.categoryId == 1 &&
              item.count == 2 &&
              item.isCompleted == false,
        )),
      )).called(1);
    });

    test('sollte Sonderzeichen im Titel erlauben', () async {
      // Arrange
      const specialTitle = 'Milch & Brot (2x kaufen!)';
        when(mockRepository.updateItem(any)).thenAnswer((_) async => {});

      // Act
      await useCase(item: testItem, newTitle: specialTitle);

      // Assert
      verify(mockRepository.updateItem(
        argThat(predicate<TodoItem>((item) => item.title == specialTitle)),
      )).called(1);
    });
  });
}

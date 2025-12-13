import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:matzo/domain/entities/todo_item.dart';
import 'package:matzo/domain/repositories/todo_item_repository.dart';
import 'package:matzo/domain/usecases/todo_item/add_todo_item.dart';

import 'add_todo_item_test.mocks.dart';

@GenerateMocks([TodoItemRepository])
void main() {
  late AddTodoItem useCase;
  late MockTodoItemRepository mockRepository;

  setUp(() {
    mockRepository = MockTodoItemRepository();
    useCase = AddTodoItem(mockRepository);
  });

  group('AddTodoItem UseCase', () {
    const testCategoryId = 1;
    const testTitle = 'Milch kaufen';

    test('sollte Item erfolgreich hinzufügen', () async {
      // Arrange
        when(mockRepository.addItem(any)).thenAnswer((_) async => 1);

      // Act
      final result = await useCase(
        categoryId: testCategoryId,
        title: testTitle,
      );

      // Assert
      expect(result, 1);
      verify(mockRepository.addItem(
        argThat(predicate<TodoItem>((item) =>
            item.categoryId == testCategoryId &&
            item.title == testTitle &&
            item.count == 1 &&
            item.isCompleted == false)),
      )).called(1);
    });

    test('sollte Whitespace trimmen', () async {
      // Arrange
      const titleWithSpaces = '  Milch kaufen  ';
        when(mockRepository.addItem(any)).thenAnswer((_) async => 1);

      // Act
      await useCase(
        categoryId: testCategoryId,
        title: titleWithSpaces,
      );

      // Assert
      verify(mockRepository.addItem(
        argThat(predicate<TodoItem>((item) => item.title == 'Milch kaufen')),
      )).called(1);
    });

    test('sollte Exception werfen bei leerem Titel', () async {
      // Act & Assert
      expect(
        () => useCase(
          categoryId: testCategoryId,
          title: '',
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('darf nicht leer sein'),
          ),
        ),
      );
      verifyNever(mockRepository.addItem(any));
    });

    test('sollte Exception werfen bei zu langem Titel (>100 Zeichen)', () async {
      // Arrange
      final longTitle = 'a' * 101;

      // Act & Assert
      expect(
        () => useCase(
          categoryId: testCategoryId,
          title: longTitle,
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('maximal 100 Zeichen'),
          ),
        ),
      );
      verifyNever(mockRepository.addItem(any));
    });

    test('sollte Titel mit genau 100 Zeichen akzeptieren', () async {
      // Arrange
      final maxLengthTitle = 'a' * 100;
        when(mockRepository.addItem(any)).thenAnswer((_) async => 1);

      // Act
      await useCase(
        categoryId: testCategoryId,
        title: maxLengthTitle,
      );

      // Assert
      verify(mockRepository.addItem(any)).called(1);
    });

    test('sollte count standardmäßig auf 1 setzen', () async {
      // Arrange
        when(mockRepository.addItem(any)).thenAnswer((_) async => 1);

      // Act
      await useCase(
        categoryId: testCategoryId,
        title: testTitle,
      );

      // Assert
      verify(mockRepository.addItem(
        argThat(predicate<TodoItem>((item) => item.count == 1)),
      )).called(1);
    });

    test('sollte isCompleted standardmäßig auf false setzen', () async {
      // Arrange
        when(mockRepository.addItem(any)).thenAnswer((_) async => 1);

      // Act
      await useCase(
        categoryId: testCategoryId,
        title: testTitle,
      );

      // Assert
      verify(mockRepository.addItem(
        argThat(predicate<TodoItem>((item) => item.isCompleted == false)),
      )).called(1);
    });
  });
}

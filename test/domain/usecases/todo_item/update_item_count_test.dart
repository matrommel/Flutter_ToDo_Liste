import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:matzo/domain/entities/todo_item.dart';
import 'package:matzo/domain/repositories/todo_item_repository.dart';
import 'package:matzo/domain/usecases/todo_item/update_item_count.dart';

import 'update_item_count_test.mocks.dart';

@GenerateMocks([TodoItemRepository])
void main() {
  late UpdateItemCount useCase;
  late MockTodoItemRepository mockRepository;

  setUp(() {
    mockRepository = MockTodoItemRepository();
    useCase = UpdateItemCount(mockRepository);
  });

  group('UpdateItemCount UseCase', () {
    late TodoItem testItem;

    setUp(() {
      testItem = TodoItem(
        id: 1,
        categoryId: 1,
        title: 'Test Item',
        count: 5,
        isCompleted: false,
        createdAt: DateTime.now(),
      );
    });

    test('sollte Anzahl erfolgreich erhöhen', () async {
      // Arrange
      when(mockRepository.updateTodoItem(any))
          .thenAnswer((_) async => {});

      // Act
      await useCase(testItem, 10);

      // Assert
      verify(mockRepository.updateTodoItem(
        argThat(predicate<TodoItem>(
          (item) => item.id == 1 && item.count == 10,
        )),
      )).called(1);
    });

    test('sollte Anzahl erfolgreich verringern', () async {
      // Arrange
      when(mockRepository.updateTodoItem(any))
          .thenAnswer((_) async => {});

      // Act
      await useCase(testItem, 2);

      // Assert
      verify(mockRepository.updateTodoItem(
        argThat(predicate<TodoItem>(
          (item) => item.id == 1 && item.count == 2,
        )),
      )).called(1);
    });

    test('sollte Anzahl von 1 akzeptieren', () async {
      // Arrange
      when(mockRepository.updateTodoItem(any))
          .thenAnswer((_) async => {});

      // Act
      await useCase(testItem, 1);

      // Assert
      verify(mockRepository.updateTodoItem(
        argThat(predicate<TodoItem>((item) => item.count == 1)),
      )).called(1);
    });

    test('sollte Exception werfen bei Anzahl < 1', () async {
      // Act & Assert
      expect(
        () => useCase(testItem, 0),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('mindestens 1'),
          ),
        ),
      );
      verifyNever(mockRepository.updateTodoItem(any));
    });

    test('sollte Exception werfen bei negativer Anzahl', () async {
      // Act & Assert
      expect(
        () => useCase(testItem, -5),
        throwsA(isA<Exception>()),
      );
      verifyNever(mockRepository.updateTodoItem(any));
    });

    test('sollte andere Felder unverändert lassen', () async {
      // Arrange
      when(mockRepository.updateTodoItem(any))
          .thenAnswer((_) async => {});

      // Act
      await useCase(testItem, 7);

      // Assert
      verify(mockRepository.updateTodoItem(
        argThat(predicate<TodoItem>(
          (item) =>
              item.id == 1 &&
              item.categoryId == 1 &&
              item.title == 'Test Item' &&
              item.isCompleted == false,
        )),
      )).called(1);
    });

    test('sollte große Anzahlen akzeptieren', () async {
      // Arrange
      when(mockRepository.updateTodoItem(any))
          .thenAnswer((_) async => {});

      // Act
      await useCase(testItem, 9999);

      // Assert
      verify(mockRepository.updateTodoItem(
        argThat(predicate<TodoItem>((item) => item.count == 9999)),
      )).called(1);
    });
  });
}

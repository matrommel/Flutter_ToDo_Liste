import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:matzo/domain/entities/todo_item.dart';
import 'package:matzo/domain/usecases/todo_item/add_todo_item.dart';
import 'package:matzo/domain/usecases/todo_item/delete_todo_item.dart';
import 'package:matzo/domain/usecases/todo_item/get_todo_items.dart';
import 'package:matzo/domain/usecases/todo_item/toggle_todo_item.dart';
import 'package:matzo/domain/usecases/todo_item/update_item_count.dart';
import 'package:matzo/domain/usecases/todo_item/update_item_order.dart';
import 'package:matzo/domain/usecases/todo_item/update_todo_item.dart';
import 'package:matzo/presentation/category/bloc/category_cubit.dart';
import 'package:matzo/presentation/category/bloc/category_state.dart';

import 'category_cubit_test.mocks.dart';

@GenerateMocks([
  GetTodoItems,
  AddTodoItem,
  ToggleTodoItem,
  UpdateItemCount,
  UpdateItemOrder,
  UpdateTodoItem,
  DeleteTodoItem,
])
void main() {
  late CategoryCubit cubit;
  late MockGetTodoItems mockGetTodoItems;
  late MockAddTodoItem mockAddTodoItem;
  late MockToggleTodoItem mockToggleTodoItem;
  late MockUpdateItemCount mockUpdateItemCount;
  late MockDeleteTodoItem mockDeleteTodoItem;

  const testCategoryId = 1;

  setUp(() {
    mockGetTodoItems = MockGetTodoItems();
    mockAddTodoItem = MockAddTodoItem();
    mockToggleTodoItem = MockToggleTodoItem();
    mockUpdateItemCount = MockUpdateItemCount();
    mockDeleteTodoItem = MockDeleteTodoItem();

    cubit = CategoryCubit(
      getTodoItems: mockGetTodoItems,
      addTodoItem: mockAddTodoItem,
      toggleTodoItem: mockToggleTodoItem,
      updateItemCount: mockUpdateItemCount,
      updateItemOrder: MockUpdateItemOrder(),
      updateTodoItem: MockUpdateTodoItem(),
      deleteTodoItem: mockDeleteTodoItem,
    );
  });

  tearDown(() {
    cubit.close();
  });

  final testItems = [
    TodoItem(
      id: 1,
      categoryId: testCategoryId,
      title: 'Äpfel',
      count: 2,
      isCompleted: false,
      createdAt: DateTime(2024, 1, 1),
    ),
    TodoItem(
      id: 2,
      categoryId: testCategoryId,
      title: 'Milch',
      count: 1,
      isCompleted: false,
      createdAt: DateTime(2024, 1, 2),
    ),
    TodoItem(
      id: 3,
      categoryId: testCategoryId,
      title: 'Brot',
      count: 3,
      isCompleted: true,
      createdAt: DateTime(2024, 1, 3),
    ),
  ];

  group('CategoryCubit', () {
    test('initialer State ist CategoryInitial', () {
      expect(cubit.state, equals(CategoryInitial()));
    });

    blocTest<CategoryCubit, CategoryState>(
      'loadItems sollte Items laden und nach Status sortieren',
      build: () {
        when(mockGetTodoItems(testCategoryId))
            .thenAnswer((_) async => testItems);
        return cubit;
      },
      act: (cubit) => cubit.loadItems(testCategoryId),
      expect: () => [
        CategoryLoading(),
        isA<CategoryLoaded>()
            .having((state) => state.items.length, 'items length', 3)
            .having((state) => state.openItems.length, 'open items', 2)
            .having((state) => state.completedItems.length, 'completed items', 1),
      ],
      verify: (_) {
        verify(mockGetTodoItems(testCategoryId)).called(1);
      },
    );

    blocTest<CategoryCubit, CategoryState>(
      'loadItems sollte leere Liste bei keinen Items zurückgeben',
      build: () {
        when(mockGetTodoItems(testCategoryId))
            .thenAnswer((_) async => []);
        return cubit;
      },
      act: (cubit) => cubit.loadItems(testCategoryId),
      expect: () => [
        CategoryLoading(),
        isA<CategoryLoaded>()
            .having((state) => state.items.isEmpty, 'items empty', true)
            .having((state) => state.openItems.isEmpty, 'open items empty', true)
            .having((state) => state.completedItems.isEmpty, 'completed items empty', true),
      ],
    );

    blocTest<CategoryCubit, CategoryState>(
      'loadItems sollte Fehler behandeln',
      build: () {
        when(mockGetTodoItems(testCategoryId))
            .thenThrow(Exception('Database error'));
        return cubit;
      },
      act: (cubit) => cubit.loadItems(testCategoryId),
      expect: () => [
        CategoryLoading(),
        isA<CategoryError>()
            .having((state) => state.message, 'error message', contains('Database error')),
      ],
    );

    blocTest<CategoryCubit, CategoryState>(
      'addNewItem sollte neues Item hinzufügen und Liste neu laden',
      build: () {
        when(mockAddTodoItem(categoryId: testCategoryId, title: 'Käse', count: 1, order: anyNamed('order')))
            .thenAnswer((_) async => 4);
        when(mockGetTodoItems(testCategoryId))
            .thenAnswer((_) async => testItems);
        return cubit;
      },
      act: (cubit) => cubit.loadItems(testCategoryId).then((_) => cubit.addNewItem('Käse')),
      expect: () => [
        CategoryLoading(),
        isA<CategoryLoaded>(),
        CategoryLoading(),
        isA<CategoryLoaded>(),
      ],
      verify: (_) {
        verify(mockAddTodoItem(categoryId: testCategoryId, title: 'Käse', count: 1, order: anyNamed('order'))).called(1);
        verify(mockGetTodoItems(testCategoryId)).called(2);
      },
    );

    blocTest<CategoryCubit, CategoryState>(
      'addNewItem sollte Fehler behandeln und Liste neu laden',
      build: () {
        when(mockAddTodoItem(categoryId: testCategoryId, title: '', count: 1, order: anyNamed('order')))
            .thenThrow(Exception('Invalid title'));
        when(mockGetTodoItems(testCategoryId))
            .thenAnswer((_) async => testItems);
        return cubit;
      },
      act: (cubit) => cubit.loadItems(testCategoryId).then((_) => cubit.addNewItem('')),
      expect: () => [
        CategoryLoading(),
        isA<CategoryLoaded>(),
        isA<CategoryError>(),
        CategoryLoading(),
        isA<CategoryLoaded>(),
      ],
    );

    blocTest<CategoryCubit, CategoryState>(
      'toggleItem sollte Item-Status umschalten und Liste neu laden',
      build: () {
        when(mockToggleTodoItem(any))
            .thenAnswer((_) async => Future.value());
        when(mockGetTodoItems(testCategoryId))
            .thenAnswer((_) async => testItems);
        return cubit;
      },
      act: (cubit) => cubit.loadItems(testCategoryId).then((_) => cubit.toggleItem(testItems[0].id!)),
      expect: () => [
        CategoryLoading(),
        isA<CategoryLoaded>(),
        CategoryLoading(),
        isA<CategoryLoaded>(),
      ],
      verify: (_) {
        verify(mockToggleTodoItem(testItems[0].id!)).called(1);
        verify(mockGetTodoItems(testCategoryId)).called(2);
      },
    );

    blocTest<CategoryCubit, CategoryState>(
      'incrementCount sollte Count erhöhen',
      build: () {
        when(mockUpdateItemCount(testItems[0].id!, 3))
            .thenAnswer((_) async => Future.value());
        when(mockGetTodoItems(testCategoryId))
            .thenAnswer((_) async => testItems);
        return cubit;
      },
      act: (cubit) => cubit.loadItems(testCategoryId).then((_) => cubit.incrementCount(testItems[0].id!, testItems[0].count)),
      expect: () => [
        CategoryLoading(),
        isA<CategoryLoaded>(),
        CategoryLoading(),
        isA<CategoryLoaded>(),
      ],
      verify: (_) {
        verify(mockUpdateItemCount(testItems[0].id!, 3)).called(1);
      },
    );

    blocTest<CategoryCubit, CategoryState>(
      'decrementCount sollte Count verringern wenn > 1',
      build: () {
        when(mockUpdateItemCount(testItems[0].id!, 1))
            .thenAnswer((_) async => Future.value());
        when(mockGetTodoItems(testCategoryId))
            .thenAnswer((_) async => testItems);
        return cubit;
      },
      act: (cubit) => cubit.loadItems(testCategoryId).then((_) => cubit.decrementCount(testItems[0].id!, testItems[0].count)),
      expect: () => [
        CategoryLoading(),
        isA<CategoryLoaded>(),
        CategoryLoading(),
        isA<CategoryLoaded>(),
      ],
      verify: (_) {
        verify(mockUpdateItemCount(testItems[0].id!, 1)).called(1);
      },
    );

    blocTest<CategoryCubit, CategoryState>(
      'decrementCount sollte nichts tun wenn Count = 1',
      build: () {
        when(mockGetTodoItems(testCategoryId))
            .thenAnswer((_) async => testItems);
        return cubit;
      },
      act: (cubit) => cubit.loadItems(testCategoryId).then((_) => cubit.decrementCount(testItems[1].id!, testItems[1].count)), // Milch hat count=1
      expect: () => [
        CategoryLoading(),
        isA<CategoryLoaded>(),
      ],
      verify: (_) {
        verifyNever(mockUpdateItemCount(any, any));
      },
    );

    blocTest<CategoryCubit, CategoryState>(
      'removeItem sollte Item löschen und Liste neu laden',
      build: () {
        when(mockDeleteTodoItem(1))
            .thenAnswer((_) async => Future.value());
        when(mockGetTodoItems(testCategoryId))
            .thenAnswer((_) async => testItems);
        return cubit;
      },
      act: (cubit) => cubit.loadItems(testCategoryId).then((_) => cubit.removeItem(1)),
      expect: () => [
        CategoryLoading(),
        isA<CategoryLoaded>(),
        CategoryLoading(),
        isA<CategoryLoaded>(),
      ],
      verify: (_) {
        verify(mockDeleteTodoItem(1)).called(1);
        verify(mockGetTodoItems(testCategoryId)).called(2);
      },
    );
  });
}

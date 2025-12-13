import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:matzo/domain/entities/category.dart';
// import 'package:matzo/domain/entities/todo_item.dart';
import 'package:matzo/domain/usecases/category/add_category.dart';
import 'package:matzo/domain/usecases/category/delete_category.dart';
import 'package:matzo/domain/usecases/category/get_categories.dart';
import 'package:matzo/domain/usecases/category/get_category_item_count.dart';
import 'package:matzo/presentation/home/bloc/home_cubit.dart';
import 'package:matzo/presentation/home/bloc/home_state.dart';

import 'home_cubit_test.mocks.dart';

import 'package:matzo/domain/usecases/todo_item/get_todo_items.dart';

@GenerateMocks([GetCategories, AddCategory, DeleteCategory, GetCategoryItemCount, GetTodoItems])
void main() {
  late HomeCubit cubit;
  late MockGetCategories mockGetCategories;
  late MockAddCategory mockAddCategory;
  late MockDeleteCategory mockDeleteCategory;
  late MockGetCategoryItemCount mockGetCategoryItemCount;
  late MockGetTodoItems mockGetTodoItems;

  setUp(() {
    mockGetCategories = MockGetCategories();
    mockAddCategory = MockAddCategory();
    mockDeleteCategory = MockDeleteCategory();
    mockGetCategoryItemCount = MockGetCategoryItemCount();
    mockGetTodoItems = MockGetTodoItems();
    
    cubit = HomeCubit(
      getCategories: mockGetCategories,
      addCategory: mockAddCategory,
      deleteCategory: mockDeleteCategory,
      getCategoryItemCount: mockGetCategoryItemCount,
      getTodoItems: mockGetTodoItems,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('HomeCubit', () {
    test('initialer State ist HomeInitial', () {
      expect(cubit.state, equals(HomeInitial()));
    });

    blocTest<HomeCubit, HomeState>(
      'sollte Kategorien erfolgreich laden',
      build: () {
        final categories = [
          Category(id: 1, name: 'Einkaufen', createdAt: DateTime.now()),
          Category(id: 2, name: 'Arbeit', createdAt: DateTime.now()),
        ];
        
        when(mockGetCategories()).thenAnswer((_) async => categories);
        when(mockGetCategoryItemCount(any)).thenAnswer((_) async => 5);
         when(mockGetTodoItems(1)).thenAnswer((_) async => []);
         when(mockGetTodoItems(2)).thenAnswer((_) async => []);
        
        return cubit;
      },
      act: (cubit) => cubit.loadCategories(),
      expect: () => [
        HomeLoading(),
        isA<HomeLoaded>()
            .having((state) => state.categories.length, 'categories count', 2)
            .having((state) => state.itemCounts.length, 'counts length', 2)
            .having((state) => state.totalItemCounts.length, 'total counts length', 2),
      ],
      verify: (_) {
        verify(mockGetCategories()).called(1);
        verify(mockGetCategoryItemCount(1)).called(1);
        verify(mockGetCategoryItemCount(2)).called(1);
        verify(mockGetTodoItems(1)).called(1);
        verify(mockGetTodoItems(2)).called(1);
      },
    );

    blocTest<HomeCubit, HomeState>(
      'sollte HomeError emittieren bei Fehler',
      build: () {
        when(mockGetCategories()).thenThrow(Exception('Database error'));
        return cubit;
      },
      act: (cubit) => cubit.loadCategories(),
      expect: () => [
        HomeLoading(),
        isA<HomeError>()
            .having(
              (state) => state.message,
              'error message',
              contains('Database error'),
            ),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'sollte neue Kategorie hinzufügen und neu laden',
      build: () {
        when(mockAddCategory('Neue Kategorie', iconCodePoint: null)).thenAnswer((_) async => 1);
        when(mockGetCategories()).thenAnswer((_) async => [
          Category(id: 1, name: 'Neue Kategorie', createdAt: DateTime.now()),
        ]);
        when(mockGetCategoryItemCount(any)).thenAnswer((_) async => 0);
        when(mockGetTodoItems(any)).thenAnswer((_) async => []);
        return cubit;
      },
      act: (cubit) => cubit.addNewCategory('Neue Kategorie'),
      expect: () => [
        HomeLoading(),
        isA<HomeLoaded>()
            .having((state) => state.categories.length, 'categories count', 1),
      ],
      verify: (_) {
        verify(mockAddCategory('Neue Kategorie', iconCodePoint: null)).called(1);
        verify(mockGetCategories()).called(1);
      },
    );

    blocTest<HomeCubit, HomeState>(
      'sollte Kategorie löschen und neu laden',
      build: () {
        when(mockDeleteCategory(any)).thenAnswer((_) async {});
        when(mockGetCategories()).thenAnswer((_) async => []);
        return cubit;
      },
      act: (cubit) => cubit.removeCategory(1),
      expect: () => [
        HomeLoading(),
        isA<HomeLoaded>()
            .having((state) => state.categories, 'categories', isEmpty),
      ],
      verify: (_) {
        verify(mockDeleteCategory(1)).called(1);
        verify(mockGetCategories()).called(1);
      },
    );

    blocTest<HomeCubit, HomeState>(
      'sollte Fehler anzeigen aber neu laden nach Add-Fehler',
      build: () {
        when(mockAddCategory(any, iconCodePoint: null)).thenThrow(Exception('Validation error'));
        when(mockGetCategories()).thenAnswer((_) async => []);
        when(mockGetCategoryItemCount(any)).thenAnswer((_) async => 0);
        return cubit;
      },
      act: (cubit) => cubit.addNewCategory(''),
      expect: () => [
        isA<HomeError>(),
        HomeLoading(),
        isA<HomeLoaded>(),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'sollte leere Liste korrekt handhaben',
      build: () {
        when(mockGetCategories()).thenAnswer((_) async => []);
        return cubit;
      },
      act: (cubit) => cubit.loadCategories(),
      expect: () => [
        HomeLoading(),
        isA<HomeLoaded>()
            .having((state) => state.categories, 'categories', isEmpty)
            .having((state) => state.itemCounts, 'counts', isEmpty),
      ],
    );
  });
}

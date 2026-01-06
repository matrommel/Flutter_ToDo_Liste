import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:matzo/domain/entities/category.dart';
import 'package:matzo/domain/usecases/category/add_category.dart';
import 'package:matzo/domain/usecases/category/delete_category.dart';
import 'package:matzo/domain/usecases/category/get_top_level_categories.dart';
import 'package:matzo/domain/usecases/category/get_subcategories.dart';
import 'package:matzo/domain/usecases/category/get_recursive_item_count.dart';
import 'package:matzo/domain/usecases/category/get_recursive_total_item_count.dart';
import 'package:matzo/domain/usecases/category/update_category.dart';
import 'package:matzo/domain/usecases/category/reorder_categories.dart';
import 'package:matzo/presentation/home/bloc/home_cubit.dart';
import 'package:matzo/presentation/home/bloc/home_state.dart';

import 'home_cubit_test.mocks.dart';

@GenerateMocks([
  GetTopLevelCategories,
  GetSubcategories,
  AddCategory,
  UpdateCategory,
  DeleteCategory,
  GetRecursiveItemCount,
  GetRecursiveTotalItemCount,
  ReorderCategories,
])
void main() {
  late HomeCubit cubit;
  late MockGetTopLevelCategories mockGetTopLevelCategories;
  late MockGetSubcategories mockGetSubcategories;
  late MockAddCategory mockAddCategory;
  late MockUpdateCategory mockUpdateCategory;
  late MockDeleteCategory mockDeleteCategory;
  late MockGetRecursiveItemCount mockGetRecursiveItemCount;
  late MockGetRecursiveTotalItemCount mockGetRecursiveTotalItemCount;
  late MockReorderCategories mockReorderCategories;

  setUp(() {
    mockGetTopLevelCategories = MockGetTopLevelCategories();
    mockGetSubcategories = MockGetSubcategories();
    mockAddCategory = MockAddCategory();
    mockUpdateCategory = MockUpdateCategory();
    mockDeleteCategory = MockDeleteCategory();
    mockGetRecursiveItemCount = MockGetRecursiveItemCount();
    mockGetRecursiveTotalItemCount = MockGetRecursiveTotalItemCount();
    mockReorderCategories = MockReorderCategories();

    cubit = HomeCubit(
      getTopLevelCategories: mockGetTopLevelCategories,
      getSubcategories: mockGetSubcategories,
      addCategory: mockAddCategory,
      updateCategory: mockUpdateCategory,
      deleteCategory: mockDeleteCategory,
      getRecursiveItemCount: mockGetRecursiveItemCount,
      getRecursiveTotalItemCount: mockGetRecursiveTotalItemCount,
      reorderCategoriesUseCase: mockReorderCategories,
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

        when(mockGetTopLevelCategories()).thenAnswer((_) async => categories);
        when(mockGetSubcategories(any)).thenAnswer((_) async => []);
        when(mockGetRecursiveItemCount(any)).thenAnswer((_) async => 5);
        when(mockGetRecursiveTotalItemCount(any)).thenAnswer((_) async => 10);

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
        verify(mockGetTopLevelCategories()).called(1);
        verify(mockGetSubcategories(1)).called(1);
        verify(mockGetSubcategories(2)).called(1);
        verify(mockGetRecursiveItemCount(1)).called(1);
        verify(mockGetRecursiveItemCount(2)).called(1);
        verify(mockGetRecursiveTotalItemCount(1)).called(1);
        verify(mockGetRecursiveTotalItemCount(2)).called(1);
      },
    );

    blocTest<HomeCubit, HomeState>(
      'sollte HomeError emittieren bei Fehler',
      build: () {
        when(mockGetTopLevelCategories()).thenThrow(Exception('Database error'));
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
        when(mockAddCategory('Neue Kategorie', iconCodePoint: null, parentCategoryId: null))
            .thenAnswer((_) async => 1);
        when(mockGetTopLevelCategories()).thenAnswer((_) async => [
          Category(id: 1, name: 'Neue Kategorie', createdAt: DateTime.now()),
        ]);
        when(mockGetSubcategories(any)).thenAnswer((_) async => []);
        when(mockGetRecursiveItemCount(any)).thenAnswer((_) async => 0);
        when(mockGetRecursiveTotalItemCount(any)).thenAnswer((_) async => 0);
        return cubit;
      },
      act: (cubit) => cubit.addNewCategory('Neue Kategorie'),
      expect: () => [
        HomeLoading(),
        isA<HomeLoaded>()
            .having((state) => state.categories.length, 'categories count', 1),
      ],
      verify: (_) {
        verify(mockAddCategory('Neue Kategorie', iconCodePoint: null, parentCategoryId: null)).called(1);
        verify(mockGetTopLevelCategories()).called(1);
      },
    );

    blocTest<HomeCubit, HomeState>(
      'sollte Kategorie löschen und neu laden',
      build: () {
        when(mockDeleteCategory(any)).thenAnswer((_) async {});
        when(mockGetTopLevelCategories()).thenAnswer((_) async => []);
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
        verify(mockGetTopLevelCategories()).called(1);
      },
    );

    blocTest<HomeCubit, HomeState>(
      'sollte Fehler anzeigen aber neu laden nach Add-Fehler',
      build: () {
        when(mockAddCategory(any, iconCodePoint: null, parentCategoryId: null))
            .thenThrow(Exception('Validation error'));
        when(mockGetTopLevelCategories()).thenAnswer((_) async => []);
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
        when(mockGetTopLevelCategories()).thenAnswer((_) async => []);
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

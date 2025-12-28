// Presentation - Home Screen Logic (Cubit)

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matzo/core/di/injection.dart';
import 'package:matzo/domain/entities/category.dart';
import 'package:matzo/domain/usecases/category/add_category.dart';
import 'package:matzo/domain/usecases/category/delete_category.dart';
import 'package:matzo/domain/usecases/category/get_top_level_categories.dart';
import 'package:matzo/domain/usecases/category/get_subcategories.dart';
import 'package:matzo/domain/usecases/category/get_recursive_item_count.dart';
import 'package:matzo/domain/usecases/category/get_recursive_total_item_count.dart';
import 'package:matzo/domain/usecases/category/update_category_protection.dart';
import 'package:matzo/domain/usecases/category/update_category.dart';
import 'package:matzo/domain/usecases/category/reorder_categories.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetTopLevelCategories getTopLevelCategories;
  final GetSubcategories getSubcategories;
  final AddCategory addCategory;
  final UpdateCategory updateCategory;
  final DeleteCategory deleteCategory;
  final GetRecursiveItemCount getRecursiveItemCount;
  final GetRecursiveTotalItemCount getRecursiveTotalItemCount;
  final ReorderCategories reorderCategoriesUseCase;

  HomeCubit({
    required this.getTopLevelCategories,
    required this.getSubcategories,
    required this.addCategory,
    required this.updateCategory,
    required this.deleteCategory,
    required this.getRecursiveItemCount,
    required this.getRecursiveTotalItemCount,
    required this.reorderCategoriesUseCase,
  }) : super(HomeInitial());

  // Kategorien laden
  Future<void> loadCategories() async {
    final currentState = state;
    final sortAscending = currentState is HomeLoaded ? currentState.sortAscending : true;

    emit(HomeLoading());
    try {
      var categories = await getTopLevelCategories();

      // Kategorien sortieren
      categories = _sortCategories(categories, sortAscending);

      // Item-Counts und Subcategories für jede Kategorie laden
      final Map<int, int> openCounts = {};
      final Map<int, int> totalCounts = {};
      final Map<int, List<Category>> subcategoriesMap = {};
      final Map<int, int> subcatOpenCounts = {};
      final Map<int, int> subcatTotalCounts = {};

      for (final category in categories) {
        if (category.id != null) {
          // Zähle rekursiv alle offenen Items in Kategorie + Subcategories
          openCounts[category.id!] = await getRecursiveItemCount(category.id!);

          // Zähle rekursiv ALLE Items (inkl. completed) in Kategorie + Subcategories
          totalCounts[category.id!] = await getRecursiveTotalItemCount(category.id!);

          // Lade Subcategories und sortiere sie
          var subcats = await getSubcategories(category.id!);
          subcats = _sortCategories(subcats, sortAscending);
          subcategoriesMap[category.id!] = subcats;

          // Lade Progress für jede Subcategory
          for (final subcat in subcats) {
            if (subcat.id != null) {
              subcatOpenCounts[subcat.id!] = await getRecursiveItemCount(subcat.id!);
              subcatTotalCounts[subcat.id!] = await getRecursiveTotalItemCount(subcat.id!);
            }
          }
        }
      }

      emit(HomeLoaded(
        categories: categories,
        itemCounts: openCounts,
        totalItemCounts: totalCounts,
        subcategories: subcategoriesMap,
        subcategoryOpenCounts: subcatOpenCounts,
        subcategoryTotalCounts: subcatTotalCounts,
        sortAscending: sortAscending,
      ));
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }

  // Kategorien sortieren (alphabetisch nach Name)
  List<Category> _sortCategories(List<Category> categories, bool ascending) {
    final sorted = List<Category>.from(categories);
    sorted.sort((a, b) {
      final comparison = a.name.toLowerCase().compareTo(b.name.toLowerCase());
      return ascending ? comparison : -comparison;
    });
    return sorted;
  }

  // Sortierreihenfolge umschalten
  void toggleSortOrder() {
    final currentState = state;
    if (currentState is HomeLoaded) {
      final newSortAscending = !currentState.sortAscending;
      final sortedCategories = _sortCategories(currentState.categories, newSortAscending);
      emit(currentState.copyWith(
        categories: sortedCategories,
        sortAscending: newSortAscending,
      ));
    }
  }

  // Kategorien neu ordnen (Drag & Drop)
  Future<void> reorderCategories(int oldIndex, int newIndex) async {
    final currentState = state;
    if (currentState is! HomeLoaded) return;

    // Adjust newIndex when dragging down
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    // Reorder in-memory
    final categories = List<Category>.from(currentState.categories);
    final movedCategory = categories.removeAt(oldIndex);
    categories.insert(newIndex, movedCategory);

    // Update UI immediately
    emit(currentState.copyWith(categories: categories));

    // Persist to database
    try {
      await reorderCategoriesUseCase(categories);
    } catch (e) {
      // On error, reload to restore correct order
      await loadCategories();
    }
  }

  // Neue Kategorie hinzufügen
  Future<void> addNewCategory(String name, {int? iconCodePoint}) async {
    try {
      await addCategory(name, iconCodePoint: iconCodePoint);
      await loadCategories(); // Neu laden
    } catch (e) {
      emit(HomeError(message: e.toString()));
      // Nach Fehler wieder in geladenen Zustand gehen
      await loadCategories();
    }
  }

  // Kategorie bearbeiten
  Future<void> editCategory(int categoryId, String newName, {int? newIconCodePoint}) async {
    try {
      await updateCategory(
        categoryId: categoryId,
        newName: newName,
        newIconCodePoint: newIconCodePoint,
      );
      await loadCategories(); // Neu laden
    } catch (e) {
      emit(HomeError(message: e.toString()));
      await loadCategories();
    }
  }

  // Kategorie löschen
  Future<void> removeCategory(int categoryId) async {
    try {
      await deleteCategory(categoryId);
      await loadCategories(); // Neu laden
    } catch (e) {
      emit(HomeError(message: e.toString()));
      await loadCategories();
    }
  }

  // Biometrischer Schutz aktualisieren
  Future<void> updateCategoryProtection(int categoryId, bool isProtected) async {
    try {
      await getIt<UpdateCategoryProtection>()(categoryId, isProtected);
      await loadCategories(); // Neu laden
    } catch (e) {
      emit(HomeError(message: e.toString()));
      await loadCategories();
    }
  }
}

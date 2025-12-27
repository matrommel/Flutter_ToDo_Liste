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
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetTopLevelCategories getTopLevelCategories;
  final GetSubcategories getSubcategories;
  final AddCategory addCategory;
  final DeleteCategory deleteCategory;
  final GetRecursiveItemCount getRecursiveItemCount;
  final GetRecursiveTotalItemCount getRecursiveTotalItemCount;

  HomeCubit({
    required this.getTopLevelCategories,
    required this.getSubcategories,
    required this.addCategory,
    required this.deleteCategory,
    required this.getRecursiveItemCount,
    required this.getRecursiveTotalItemCount,
  }) : super(HomeInitial());

  // Kategorien laden
  Future<void> loadCategories() async {
    emit(HomeLoading());
    try {
      final categories = await getTopLevelCategories();

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

          // Lade Subcategories
          final subcats = await getSubcategories(category.id!);
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
      ));
    } catch (e) {
      emit(HomeError(message: e.toString()));
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

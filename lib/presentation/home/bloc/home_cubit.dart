// Presentation - Home Screen Logic (Cubit)

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matzo/core/di/injection.dart';
import 'package:matzo/domain/usecases/category/add_category.dart';
import 'package:matzo/domain/usecases/category/delete_category.dart';
import 'package:matzo/domain/usecases/category/get_categories.dart';
import 'package:matzo/domain/usecases/category/get_category_item_count.dart';
import 'package:matzo/domain/usecases/category/update_category_protection.dart';
import 'package:matzo/domain/usecases/todo_item/get_todo_items.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetCategories getCategories;
  final AddCategory addCategory;
  final DeleteCategory deleteCategory;
  final GetCategoryItemCount getCategoryItemCount;
  final GetTodoItems getTodoItems;

  HomeCubit({
    required this.getCategories,
    required this.addCategory,
    required this.deleteCategory,
    required this.getCategoryItemCount,
    required this.getTodoItems,
  }) : super(HomeInitial());

  // Kategorien laden
  Future<void> loadCategories() async {
    emit(HomeLoading());
    try {
      final categories = await getCategories();
      
      // Item-Counts für jede Kategorie laden
      final Map<int, int> openCounts = {};
      final Map<int, int> totalCounts = {};
      
      for (final category in categories) {
        if (category.id != null) {
          openCounts[category.id!] = await getCategoryItemCount(category.id!);
          
          // Hole alle Items um die Gesamtzahl zu bekommen
          final allItems = await getTodoItems(category.id!);
          totalCounts[category.id!] = allItems.length;
        }
      }

      emit(HomeLoaded(
        categories: categories, 
        itemCounts: openCounts,
        totalItemCounts: totalCounts,
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

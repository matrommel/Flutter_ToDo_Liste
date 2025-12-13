// Presentation - Category Screen Logic (Cubit)

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matzo/domain/entities/todo_item.dart';
import 'package:matzo/domain/usecases/todo_item/add_todo_item.dart';
import 'package:matzo/domain/usecases/todo_item/delete_todo_item.dart';
import 'package:matzo/domain/usecases/todo_item/get_todo_items.dart';
import 'package:matzo/domain/usecases/todo_item/toggle_todo_item.dart';
import 'package:matzo/domain/usecases/todo_item/update_item_count.dart';
import 'package:matzo/domain/usecases/todo_item/update_item_order.dart';
import 'package:matzo/domain/usecases/todo_item/update_todo_item.dart';
import 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final GetTodoItems getTodoItems;
  final AddTodoItem addTodoItem;
  final ToggleTodoItem toggleTodoItem;
  final UpdateItemCount updateItemCount;
  final UpdateItemOrder updateItemOrder;
  final UpdateTodoItem updateTodoItem;
  final DeleteTodoItem deleteTodoItem;

  int? _currentCategoryId;
  TodoItem? _lastDeletedItem;
  bool _showCompleted = true;
  bool _sortAscending = true;

  CategoryCubit({
    required this.getTodoItems,
    required this.addTodoItem,
    required this.toggleTodoItem,
    required this.updateItemCount,
    required this.updateItemOrder,
    required this.updateTodoItem,
    required this.deleteTodoItem,
  }) : super(CategoryInitial());

  // Items einer Kategorie laden
  Future<void> loadItems(int categoryId) async {
    _currentCategoryId = categoryId;
    emit(CategoryLoading());
    try {
      final items = await getTodoItems(categoryId);
      emit(
        CategoryLoaded(
          items: _sortedItems(items),
          showCompleted: _showCompleted,
          sortAscending: _sortAscending,
        ),
      );
    } catch (e) {
      emit(CategoryError(message: e.toString()));
    }
  }

  // Neues Item hinzufügen
  Future<void> addNewItem(String title, {int count = 1}) async {
    if (_currentCategoryId == null) return;

    try {
      final currentState = state;

      // Falls Item bereits existiert: Zähler erhöhen statt neues anlegen
      if (currentState is CategoryLoaded) {
        final normalized = title.trim().toLowerCase();
        TodoItem? existing;
        try {
          existing = currentState.items.firstWhere(
            (item) => item.title.toLowerCase() == normalized,
          );
        } catch (_) {
          existing = null;
        }

        if (existing != null && existing.id != null) {
          if (existing.isCompleted) {
            await toggleTodoItem(existing.id!);
          }
          await updateItemCount(existing.id!, existing.count + count);
          await loadItems(_currentCategoryId!);
          return;
        }

        final nextOrder = currentState.items.isEmpty
            ? 0
            : (currentState.items.map((e) => e.order).reduce((a, b) => a > b ? a : b) + 1);

        await addTodoItem(
          categoryId: _currentCategoryId!,
          title: title,
          count: count,
          order: nextOrder,
        );
        await loadItems(_currentCategoryId!); // Neu laden
        return;
      }

      await addTodoItem(
        categoryId: _currentCategoryId!,
        title: title,
        count: count,
        order: 0,
      );
      await loadItems(_currentCategoryId!); // Neu laden
    } catch (e) {
      emit(CategoryError(message: e.toString()));
      if (_currentCategoryId != null) {
        await loadItems(_currentCategoryId!);
      }
    }
  }

  // Item abhaken/aufheben
  Future<void> toggleItem(int itemId) async {
    if (_currentCategoryId == null) return;

    try {
      await toggleTodoItem(itemId);
      await loadItems(_currentCategoryId!); // Neu laden
    } catch (e) {
      emit(CategoryError(message: e.toString()));
      if (_currentCategoryId != null) {
        await loadItems(_currentCategoryId!);
      }
    }
  }

  // Anzahl erhöhen
  Future<void> incrementCount(int itemId, int currentCount) async {
    if (_currentCategoryId == null) return;

    try {
      await updateItemCount(itemId, currentCount + 1);
      await loadItems(_currentCategoryId!);
    } catch (e) {
      emit(CategoryError(message: e.toString()));
      if (_currentCategoryId != null) {
        await loadItems(_currentCategoryId!);
      }
    }
  }

  // Anzahl verringern
  Future<void> decrementCount(int itemId, int currentCount) async {
    if (_currentCategoryId == null) return;
    if (currentCount <= 1) return; // Minimum 1

    try {
      await updateItemCount(itemId, currentCount - 1);
      await loadItems(_currentCategoryId!);
    } catch (e) {
      emit(CategoryError(message: e.toString()));
      if (_currentCategoryId != null) {
        await loadItems(_currentCategoryId!);
      }
    }
  }

  // Item löschen (mit Undo-Support)
  Future<void> removeItem(int itemId) async {
    if (_currentCategoryId == null) return;

    try {
      // Item für Undo speichern
      final currentState = state;
      if (currentState is CategoryLoaded) {
        _lastDeletedItem = currentState.items.firstWhere(
          (item) => item.id == itemId,
          orElse: () => throw Exception('Item not found'),
        );
      }
      
      await deleteTodoItem(itemId);
      await loadItems(_currentCategoryId!);
    } catch (e) {
      emit(CategoryError(message: e.toString()));
      if (_currentCategoryId != null) {
        await loadItems(_currentCategoryId!);
      }
    }
  }

  // Item bearbeiten
  Future<void> editItem(int itemId, String newTitle, int newCount) async {
    if (_currentCategoryId == null) return;

    try {
      final currentState = state;
      if (currentState is! CategoryLoaded) return;

      final item = currentState.items.firstWhere(
        (i) => i.id == itemId,
        orElse: () => throw Exception('Item not found'),
      );

      await updateTodoItem(
        item: item,
        newTitle: newTitle,
        newCount: newCount,
      );

      await loadItems(_currentCategoryId!);
    } catch (e) {
      emit(CategoryError(message: e.toString()));
      if (_currentCategoryId != null) {
        await loadItems(_currentCategoryId!);
      }
    }
  }

  // Gelöschtes Item wiederherstellen (für Undo)
  Future<void> restoreLastDeletedItem() async {
    if (_lastDeletedItem == null || _currentCategoryId == null) return;

    try {
      await addTodoItem(
        categoryId: _lastDeletedItem!.categoryId,
        title: _lastDeletedItem!.title,
        count: _lastDeletedItem!.count,
        order: _lastDeletedItem!.order,
      );
      _lastDeletedItem = null;
      await loadItems(_currentCategoryId!);
    } catch (e) {
      emit(CategoryError(message: e.toString()));
      if (_currentCategoryId != null) {
        await loadItems(_currentCategoryId!);
      }
    }
  }

  // Alle offenen Items als erledigt markieren
  Future<void> markAllAsComplete() async {
    if (_currentCategoryId == null) return;

    try {
      final currentState = state;
      if (currentState is! CategoryLoaded) return;

      for (final item in currentState.openItems) {
        await toggleTodoItem(item.id!);
      }

      await loadItems(_currentCategoryId!);
    } catch (e) {
      emit(CategoryError(message: e.toString()));
      if (_currentCategoryId != null) {
        await loadItems(_currentCategoryId!);
      }
    }
  }

  // Items umsortieren (offene Liste)
    Future<void> reorderOpenItems(int oldIndex, int newIndex) async {
      if (_currentCategoryId == null) return;

      final currentState = state;
      if (currentState is! CategoryLoaded) return;

      final openItems = List<TodoItem>.from(currentState.openItems);
      if (newIndex > oldIndex) newIndex -= 1;

      final item = openItems.removeAt(oldIndex);
      openItems.insert(newIndex, item);

      // Persist neue Reihenfolge
      for (var i = 0; i < openItems.length; i++) {
        await updateItemOrder(openItems[i].id!, i);
      }

      // Completed Items behalten ihre Reihenfolge
      final combined = [...openItems, ...currentState.completedItems];
      emit(
        CategoryLoaded(
          items: _sortedItems(combined),
          showCompleted: _showCompleted,
          sortAscending: _sortAscending,
        ),
      );
    }

  void toggleShowCompleted() {
      if (state is CategoryLoaded) {
        _showCompleted = !_showCompleted;
        final current = state as CategoryLoaded;
        emit(
          CategoryLoaded(
            items: current.items,
            showCompleted: _showCompleted,
            sortAscending: _sortAscending,
          ),
        );
      }
    }

  void toggleSortOrder() {
      if (state is CategoryLoaded) {
        _sortAscending = !_sortAscending;
        final current = state as CategoryLoaded;
        emit(
          CategoryLoaded(
            items: _sortedItems(current.items),
            showCompleted: _showCompleted,
            sortAscending: _sortAscending,
          ),
        );
      }
    }

  List<TodoItem> _sortedItems(List<TodoItem> items) {
      int compareItems(TodoItem a, TodoItem b) {
        final orderCompare = a.order.compareTo(b.order);
        if (orderCompare != 0) return orderCompare;
        final createdCompare = a.createdAt.compareTo(b.createdAt);
        if (createdCompare != 0) return createdCompare;
        return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      }

      final open = List<TodoItem>.from(items.where((i) => !i.isCompleted))..sort(compareItems);
      final completed = List<TodoItem>.from(items.where((i) => i.isCompleted))..sort(compareItems);

      final orderedOpen = _sortAscending ? open : open.reversed.toList();
      final orderedCompleted = _sortAscending ? completed : completed.reversed.toList();

      return [...orderedOpen, ...orderedCompleted];
    }

  // Alle erledigten Items löschen
  Future<void> deleteAllCompleted() async {
    if (_currentCategoryId == null) return;

    try {
      final currentState = state;
      if (currentState is! CategoryLoaded) return;

      for (final item in currentState.completedItems) {
        await deleteTodoItem(item.id!);
      }

      await loadItems(_currentCategoryId!);
    } catch (e) {
      emit(CategoryError(message: e.toString()));
      if (_currentCategoryId != null) {
        await loadItems(_currentCategoryId!);
      }
    }
  }
}

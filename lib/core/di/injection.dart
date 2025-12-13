// Core - Dependency Injection mit GetIt

import 'package:get_it/get_it.dart';

import 'package:matzo/data/datasources/local/category_local_datasource.dart';
import 'package:matzo/data/datasources/local/database_helper.dart';
import 'package:matzo/data/datasources/local/todo_item_local_datasource.dart';
import 'package:matzo/data/repositories/category_repository_impl.dart';
import 'package:matzo/data/repositories/todo_item_repository_impl.dart';
import 'package:matzo/domain/repositories/category_repository.dart';
import 'package:matzo/domain/repositories/todo_item_repository.dart';
import 'package:matzo/domain/usecases/category/add_category.dart';
import 'package:matzo/domain/usecases/category/delete_category.dart';
import 'package:matzo/domain/usecases/category/get_categories.dart';
import 'package:matzo/domain/usecases/category/get_category_item_count.dart';
import 'package:matzo/domain/usecases/category/reorder_categories.dart';
import 'package:matzo/domain/usecases/todo_item/add_todo_item.dart';
import 'package:matzo/domain/usecases/todo_item/delete_todo_item.dart';
import 'package:matzo/domain/usecases/todo_item/edit_todo_item.dart';
import 'package:matzo/domain/usecases/todo_item/get_todo_items.dart';
import 'package:matzo/domain/usecases/todo_item/toggle_todo_item.dart';
import 'package:matzo/domain/usecases/todo_item/update_item_count.dart';
import 'package:matzo/domain/usecases/todo_item/update_item_order.dart';
import 'package:matzo/domain/usecases/todo_item/update_todo_item.dart';
import 'package:matzo/domain/usecases/search/search_todo_items.dart';
import 'package:matzo/presentation/category/bloc/category_cubit.dart';
import 'package:matzo/presentation/home/bloc/home_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // ============ Presentation Layer ============
  // Cubits (Factory = neue Instanz bei jedem Aufruf)
  getIt.registerFactory(
    () => HomeCubit(
      getCategories: getIt(),
      addCategory: getIt(),
      deleteCategory: getIt(),
      getCategoryItemCount: getIt(),
      getTodoItems: getIt(),
    ),
  );

  getIt.registerFactory(
    () => CategoryCubit(
      getTodoItems: getIt(),
      addTodoItem: getIt(),
      toggleTodoItem: getIt(),
      updateItemCount: getIt(),
      updateItemOrder: getIt(),
      updateTodoItem: getIt(),
      deleteTodoItem: getIt(),
    ),
  );

  // ============ Domain Layer ============
  // Use Cases
  getIt.registerLazySingleton(() => GetCategories(getIt()));
  getIt.registerLazySingleton(() => AddCategory(getIt()));
  getIt.registerLazySingleton(() => DeleteCategory(getIt()));
  getIt.registerLazySingleton(() => GetCategoryItemCount(getIt()));
  getIt.registerLazySingleton(() => ReorderCategories(getIt()));

  getIt.registerLazySingleton(() => GetTodoItems(getIt()));
  getIt.registerLazySingleton(() => AddTodoItem(getIt()));
  getIt.registerLazySingleton(() => ToggleTodoItem(getIt()));
  getIt.registerLazySingleton(() => UpdateItemCount(getIt()));
  getIt.registerLazySingleton(() => UpdateItemOrder(getIt()));
  getIt.registerLazySingleton(() => UpdateTodoItem(getIt()));
  getIt.registerLazySingleton(() => DeleteTodoItem(getIt()));
  getIt.registerLazySingleton(() => EditTodoItem(getIt()));
  
  getIt.registerLazySingleton(() => SearchTodoItems(
    categoryRepository: getIt(),
    todoItemRepository: getIt(),
  ));

  // ============ Data Layer ============
  // Repositories
  getIt.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<TodoItemRepository>(
    () => TodoItemRepositoryImpl(getIt()),
  );

  // Data Sources
  getIt.registerLazySingleton(() => CategoryLocalDataSource(getIt()));
  getIt.registerLazySingleton(() => TodoItemLocalDataSource(getIt()));

  // Database
  getIt.registerLazySingleton(() => DatabaseHelper.instance);
}

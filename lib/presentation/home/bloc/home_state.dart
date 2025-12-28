// Presentation - Home Screen States

import 'package:equatable/equatable.dart';
import 'package:matzo/domain/entities/category.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<Category> categories;
  final Map<int, int> itemCounts; // categoryId -> offene Items Count
  final Map<int, int> totalItemCounts; // categoryId -> gesamt Items Count
  final Map<int, List<Category>> subcategories; // categoryId -> Subcategories
  final Map<int, int> subcategoryOpenCounts; // subcategoryId -> offene Items Count
  final Map<int, int> subcategoryTotalCounts; // subcategoryId -> gesamt Items Count
  final bool sortAscending; // Sortierreihenfolge

  const HomeLoaded({
    required this.categories,
    this.itemCounts = const {},
    this.totalItemCounts = const {},
    this.subcategories = const {},
    this.subcategoryOpenCounts = const {},
    this.subcategoryTotalCounts = const {},
    this.sortAscending = true,
  });

  HomeLoaded copyWith({
    List<Category>? categories,
    Map<int, int>? itemCounts,
    Map<int, int>? totalItemCounts,
    Map<int, List<Category>>? subcategories,
    Map<int, int>? subcategoryOpenCounts,
    Map<int, int>? subcategoryTotalCounts,
    bool? sortAscending,
  }) {
    return HomeLoaded(
      categories: categories ?? this.categories,
      itemCounts: itemCounts ?? this.itemCounts,
      totalItemCounts: totalItemCounts ?? this.totalItemCounts,
      subcategories: subcategories ?? this.subcategories,
      subcategoryOpenCounts: subcategoryOpenCounts ?? this.subcategoryOpenCounts,
      subcategoryTotalCounts: subcategoryTotalCounts ?? this.subcategoryTotalCounts,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }

  @override
  List<Object?> get props => [
        categories,
        itemCounts,
        totalItemCounts,
        subcategories,
        subcategoryOpenCounts,
        subcategoryTotalCounts,
        sortAscending,
      ];
}

class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});

  @override
  List<Object?> get props => [message];
}

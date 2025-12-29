// Data Layer - Data Transfer Repository Implementation
// Implementiert Export/Import-Logik mit Merge-Strategie

import 'package:package_info_plus/package_info_plus.dart';

import '../../domain/entities/category.dart';
import '../../domain/entities/export_data.dart';
import '../../domain/entities/todo_item.dart';
import '../../domain/repositories/data_transfer_repository.dart';
import '../datasources/local/i_category_local_datasource.dart';
import '../datasources/local/i_todo_item_local_datasource.dart';
import '../models/category_model.dart';
import '../models/todo_item_model.dart';

/// Implementierung des DataTransferRepository
/// Verwaltet Export/Import mit intelligenter Merge-Logik
class DataTransferRepositoryImpl implements DataTransferRepository {
  final ICategoryLocalDataSource categoryDataSource;
  final ITodoItemLocalDataSource todoItemDataSource;

  DataTransferRepositoryImpl(
    this.categoryDataSource,
    this.todoItemDataSource,
  );

  @override
  Future<ExportData> generateExportData() async {
    // 1. Hole alle Top-Level-Kategorien
    final topLevelCategories = await categoryDataSource.getTopLevelCategories();

    // 2. Baue hierarchische Struktur rekursiv
    final exportCategories = <ExportCategory>[];
    for (final category in topLevelCategories) {
      exportCategories.add(await _buildExportCategory(category));
    }

    // 3. Hole App-Version
    final packageInfo = await PackageInfo.fromPlatform();

    return ExportData(
      version: '1.0',
      exportDate: DateTime.now(),
      appVersion: packageInfo.version,
      categories: exportCategories,
    );
  }

  /// Baut ExportCategory rekursiv mit Unterkategorien und Items
  Future<ExportCategory> _buildExportCategory(Category category) async {
    // Rekursiv alle Unterkategorien holen
    final subcategories = await categoryDataSource.getSubcategories(category.id!);
    final exportSubcats = <ExportCategory>[];
    for (final subcat in subcategories) {
      exportSubcats.add(await _buildExportCategory(subcat));
    }

    // Alle Items dieser Kategorie holen (inkl. erledigte!)
    final items = await todoItemDataSource.getItemsByCategory(category.id!);
    final exportItems = items
        .map((item) => ExportItem(
              title: item.title,
              count: item.count,
              order: item.order,
              isCompleted: item.isCompleted,
              createdAt: item.createdAt,
              completedAt: item.completedAt,
              description: item.description,
              links: item.links,
            ))
        .toList();

    return ExportCategory(
      name: category.name,
      iconCodePoint: category.iconCodePoint,
      isProtected: category.isProtected,
      order: category.order,
      subcategories: exportSubcats,
      items: exportItems,
    );
  }

  @override
  Future<ImportResult> importData({
    required ExportData data,
    required bool deleteExistingData,
  }) async {
    int categoriesAdded = 0;
    int categoriesMerged = 0;
    int itemsAdded = 0;

    // 1. Lösche alle existierenden Daten falls gewünscht
    if (deleteExistingData) {
      await _deleteAllData();
    }

    // 2. Importiere jede Top-Level-Kategorie rekursiv
    for (final exportCat in data.categories) {
      final result = await _importCategoryRecursive(
        exportCat,
        parentId: null,
      );
      categoriesAdded += result.categoriesAdded;
      categoriesMerged += result.categoriesMerged;
      itemsAdded += result.itemsAdded;
    }

    return ImportResult(
      categoriesAdded: categoriesAdded,
      itemsAdded: itemsAdded,
      categoriesMerged: categoriesMerged,
    );
  }

  /// Importiert Kategorie rekursiv mit Merge-Logik
  Future<ImportResult> _importCategoryRecursive(
    ExportCategory exportCat, {
    required int? parentId,
  }) async {
    int categoriesAdded = 0;
    int categoriesMerged = 0;
    int itemsAdded = 0;

    // 1. Hole existierende Kategorien auf dieser Ebene
    final existingCategories = parentId == null
        ? await categoryDataSource.getTopLevelCategories()
        : await categoryDataSource.getSubcategories(parentId);

    // 2. Suche Match: Gleicher Name UND gleiches iconCodePoint
    Category? matchingCategory;
    for (final existing in existingCategories) {
      if (existing.name == exportCat.name &&
          existing.iconCodePoint == exportCat.iconCodePoint) {
        matchingCategory = existing;
        break;
      }
    }

    // 3. Bestimme finalen Namen (mit Konflikt-Resolution falls nötig)
    String finalName = exportCat.name;
    if (matchingCategory == null) {
      // Kein exakter Match, aber prüfe auf Name-Konflikt (anderes Icon)
      final nameConflict =
          existingCategories.any((c) => c.name == exportCat.name);
      if (nameConflict) {
        finalName = _resolveNameConflict(exportCat.name, existingCategories);
      }
    }

    // 4. Erstelle oder verwende existierende Kategorie
    int categoryId;
    if (matchingCategory != null) {
      // Match gefunden → Merge
      categoryId = matchingCategory.id!;
      categoriesMerged++;
    } else {
      // Keine Match → Neue Kategorie erstellen
      final newCategory = Category(
        name: finalName,
        createdAt: DateTime.now(),
        iconCodePoint: exportCat.iconCodePoint,
        isProtected: exportCat.isProtected,
        order: exportCat.order,
        parentCategoryId: parentId,
      );
      categoryId = await categoryDataSource.insertCategory(
        CategoryModel.fromEntity(newCategory),
      );
      categoriesAdded++;
    }

    // 5. Importiere Items in diese Kategorie
    for (final exportItem in exportCat.items) {
      final added = await _importItem(exportItem, categoryId);
      itemsAdded += added;
    }

    // 6. Importiere Unterkategorien rekursiv
    for (final subcat in exportCat.subcategories) {
      final result = await _importCategoryRecursive(
        subcat,
        parentId: categoryId,
      );
      categoriesAdded += result.categoriesAdded;
      categoriesMerged += result.categoriesMerged;
      itemsAdded += result.itemsAdded;
    }

    return ImportResult(
      categoriesAdded: categoriesAdded,
      itemsAdded: itemsAdded,
      categoriesMerged: categoriesMerged,
    );
  }

  /// Löst Name-Konflikte durch Anhängen von " (2)", " (3)", etc.
  String _resolveNameConflict(String name, List<Category> existing) {
    int suffix = 2;
    while (true) {
      final candidateName = '$name ($suffix)';
      if (!existing.any((c) => c.name == candidateName)) {
        return candidateName;
      }
      suffix++;
    }
  }

  /// Importiert ein einzelnes Item mit Merge-Logik
  /// Returns: 1 wenn neues Item, 0 wenn gemerged
  Future<int> _importItem(ExportItem exportItem, int categoryId) async {
    // Hole existierende Items in dieser Kategorie
    final existingItems =
        await todoItemDataSource.getItemsByCategory(categoryId);

    // Suche Item mit gleichem Titel
    TodoItem? matchingItem;
    for (final item in existingItems) {
      if (item.title == exportItem.title) {
        matchingItem = item;
        break;
      }
    }

    if (matchingItem != null) {
      // Item existiert → Merge: Counts addieren
      final newCount = matchingItem.count + exportItem.count;
      await todoItemDataSource.updateItemCount(matchingItem.id!, newCount);
      return 0; // Kein neues Item
    } else {
      // Item existiert nicht → Neu erstellen
      final newItem = TodoItem(
        categoryId: categoryId,
        title: exportItem.title,
        count: exportItem.count,
        order: exportItem.order,
        isCompleted: exportItem.isCompleted,
        createdAt: exportItem.createdAt,
        completedAt: exportItem.completedAt,
        description: exportItem.description,
        links: exportItem.links,
      );
      await todoItemDataSource.insertItem(TodoItemModel.fromEntity(newItem));
      return 1; // Neues Item
    }
  }

  /// Löscht alle Kategorien und Items (CASCADE)
  Future<void> _deleteAllData() async {
    final allCategories = await categoryDataSource.getAllCategories();
    for (final category in allCategories) {
      await categoryDataSource.deleteCategory(category.id!);
    }
  }

  @override
  Future<ValidationResult> validateImportData(ExportData data) async {
    try {
      // 1. Version prüfen
      if (data.version != '1.0') {
        return ValidationResult.invalid(
          'Nicht unterstützte Version: ${data.version}. Erwartet: 1.0',
        );
      }

      // 2. Mindestens eine Kategorie
      if (data.categories.isEmpty) {
        return ValidationResult.invalid(
          'Keine Kategorien in der Import-Datei gefunden',
        );
      }

      // 3. Validiere jede Kategorie rekursiv
      for (final category in data.categories) {
        final categoryValid = _validateCategory(category);
        if (!categoryValid.isValid) {
          return categoryValid;
        }
      }

      return const ValidationResult.valid();
    } catch (e) {
      return ValidationResult.invalid('Validierungsfehler: $e');
    }
  }

  /// Validiert einzelne Kategorie und ihre Inhalte rekursiv
  ValidationResult _validateCategory(ExportCategory category) {
    // Name erforderlich
    if (category.name.trim().isEmpty) {
      return const ValidationResult.invalid(
        'Kategorie ohne Namen gefunden',
      );
    }

    // Validiere Items
    for (final item in category.items) {
      if (item.title.trim().isEmpty) {
        return ValidationResult.invalid(
          'Item ohne Titel in Kategorie "${category.name}" gefunden',
        );
      }
      if (item.count < 1) {
        return ValidationResult.invalid(
          'Item "${item.title}" in Kategorie "${category.name}" '
          'hat ungültigen Count: ${item.count}',
        );
      }
    }

    // Validiere Unterkategorien rekursiv
    for (final subcat in category.subcategories) {
      final result = _validateCategory(subcat);
      if (!result.isValid) return result;
    }

    return const ValidationResult.valid();
  }
}

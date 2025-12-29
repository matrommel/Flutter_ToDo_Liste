// Domain Layer - Export/Import Data Transfer Objects
// DTOs für den Datenaustausch zwischen Export und Import

import 'package:equatable/equatable.dart';

/// Top-level container für Export-Daten
/// Enthält Metadaten und alle Kategorien
class ExportData extends Equatable {
  final String version;
  final DateTime exportDate;
  final String appVersion;
  final List<ExportCategory> categories;

  const ExportData({
    required this.version,
    required this.exportDate,
    required this.appVersion,
    required this.categories,
  });

  @override
  List<Object?> get props => [version, exportDate, appVersion, categories];
}

/// Export-Repräsentation einer Kategorie
/// Enthält verschachtelte Unterkategorien und Items
class ExportCategory extends Equatable {
  final String name;
  final int? iconCodePoint;
  final bool isProtected;
  final int order;
  final List<ExportCategory> subcategories;
  final List<ExportItem> items;

  const ExportCategory({
    required this.name,
    this.iconCodePoint,
    required this.isProtected,
    required this.order,
    required this.subcategories,
    required this.items,
  });

  @override
  List<Object?> get props => [
        name,
        iconCodePoint,
        isProtected,
        order,
        subcategories,
        items,
      ];
}

/// Export-Repräsentation eines Todo-Items
/// Enthält alle Item-Daten ohne Datenbank-ID
class ExportItem extends Equatable {
  final String title;
  final int count;
  final int order;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? description;
  final List<String>? links;

  const ExportItem({
    required this.title,
    required this.count,
    required this.order,
    required this.isCompleted,
    required this.createdAt,
    this.completedAt,
    this.description,
    this.links,
  });

  @override
  List<Object?> get props => [
        title,
        count,
        order,
        isCompleted,
        createdAt,
        completedAt,
        description,
        links,
      ];
}

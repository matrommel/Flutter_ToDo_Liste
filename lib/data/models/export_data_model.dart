// Data Layer - Export/Import Data Models mit JSON Serialization
// Erweitert Domain-Entities um JSON-Konvertierung

import 'dart:convert';

import '../../domain/entities/export_data.dart';

/// Model für ExportData mit JSON-Serialization
class ExportDataModel extends ExportData {
  const ExportDataModel({
    required super.version,
    required super.exportDate,
    required super.appVersion,
    required super.categories,
  });

  /// Konvertiert Entity zu Model
  factory ExportDataModel.fromEntity(ExportData entity) {
    return ExportDataModel(
      version: entity.version,
      exportDate: entity.exportDate,
      appVersion: entity.appVersion,
      categories: entity.categories
          .map((c) => ExportCategoryModel.fromEntity(c))
          .toList(),
    );
  }

  /// Serialisiert zu JSON Map
  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'exportDate': exportDate.toIso8601String(),
      'appVersion': appVersion,
      'categories': categories
          .map((c) => (c as ExportCategoryModel).toJson())
          .toList(),
    };
  }

  /// Deserialisiert von JSON Map
  factory ExportDataModel.fromJson(Map<String, dynamic> json) {
    return ExportDataModel(
      version: json['version'] as String,
      exportDate: DateTime.parse(json['exportDate'] as String),
      appVersion: json['appVersion'] as String,
      categories: (json['categories'] as List)
          .map((c) => ExportCategoryModel.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Konvertiert zu pretty-printed JSON String
  String toJsonString() {
    const encoder = JsonEncoder.withIndent('  '); // 2 Leerzeichen Indent
    return encoder.convert(toJson());
  }

  /// Parst JSON String zu ExportDataModel
  factory ExportDataModel.fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return ExportDataModel.fromJson(json);
  }
}

/// Model für ExportCategory mit JSON-Serialization
class ExportCategoryModel extends ExportCategory {
  const ExportCategoryModel({
    required super.name,
    super.iconCodePoint,
    required super.isProtected,
    required super.order,
    required super.subcategories,
    required super.items,
  });

  /// Konvertiert Entity zu Model
  factory ExportCategoryModel.fromEntity(ExportCategory entity) {
    return ExportCategoryModel(
      name: entity.name,
      iconCodePoint: entity.iconCodePoint,
      isProtected: entity.isProtected,
      order: entity.order,
      subcategories: entity.subcategories
          .map((s) => ExportCategoryModel.fromEntity(s))
          .toList(),
      items: entity.items
          .map((i) => ExportItemModel.fromEntity(i))
          .toList(),
    );
  }

  /// Serialisiert zu JSON Map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'iconCodePoint': iconCodePoint,
      'isProtected': isProtected,
      'order': order,
      'subcategories': subcategories
          .map((s) => (s as ExportCategoryModel).toJson())
          .toList(),
      'items': items
          .map((i) => (i as ExportItemModel).toJson())
          .toList(),
    };
  }

  /// Deserialisiert von JSON Map
  factory ExportCategoryModel.fromJson(Map<String, dynamic> json) {
    return ExportCategoryModel(
      name: json['name'] as String,
      iconCodePoint: json['iconCodePoint'] as int?,
      isProtected: json['isProtected'] as bool,
      order: json['order'] as int,
      subcategories: (json['subcategories'] as List)
          .map((s) => ExportCategoryModel.fromJson(s as Map<String, dynamic>))
          .toList(),
      items: (json['items'] as List)
          .map((i) => ExportItemModel.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Model für ExportItem mit JSON-Serialization
class ExportItemModel extends ExportItem {
  const ExportItemModel({
    required super.title,
    required super.count,
    required super.order,
    required super.isCompleted,
    required super.createdAt,
    super.completedAt,
    super.description,
    super.links,
  });

  /// Konvertiert Entity zu Model
  factory ExportItemModel.fromEntity(ExportItem entity) {
    return ExportItemModel(
      title: entity.title,
      count: entity.count,
      order: entity.order,
      isCompleted: entity.isCompleted,
      createdAt: entity.createdAt,
      completedAt: entity.completedAt,
      description: entity.description,
      links: entity.links,
    );
  }

  /// Serialisiert zu JSON Map
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'count': count,
      'order': order,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'description': description,
      'links': links,
    };
  }

  /// Deserialisiert von JSON Map
  factory ExportItemModel.fromJson(Map<String, dynamic> json) {
    return ExportItemModel(
      title: json['title'] as String,
      count: json['count'] as int,
      order: json['order'] as int,
      isCompleted: json['isCompleted'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      description: json['description'] as String?,
      links: json['links'] != null
          ? (json['links'] as List).map((l) => l as String).toList()
          : null,
    );
  }
}

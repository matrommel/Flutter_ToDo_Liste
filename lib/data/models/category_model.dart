// Data Layer - Category Model mit DB-Mapping

import 'package:matzo/domain/entities/category.dart';

class CategoryModel extends Category {
  const CategoryModel({
    super.id,
    required super.name,
    required super.createdAt,
    super.order,
    super.iconCodePoint,
    super.isProtected,
    super.parentCategoryId,
  });

  // Von Domain Entity erstellen
  factory CategoryModel.fromEntity(Category category) {
    return CategoryModel(
      id: category.id,
      name: category.name,
      createdAt: category.createdAt,
      order: category.order,
      iconCodePoint: category.iconCodePoint,
      isProtected: category.isProtected,
      parentCategoryId: category.parentCategoryId,
    );
  }

  // Von Datenbank Map erstellen
  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      order: map['order_num'] as int? ?? 0,
      iconCodePoint: map['icon_code'] as int?,
      isProtected: (map['is_protected'] as int? ?? 0) == 1,
      parentCategoryId: map['parent_category_id'] as int?,
    );
  }

  // Zu Datenbank Map konvertieren
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'created_at': createdAt.millisecondsSinceEpoch,
      'order_num': order,
      'icon_code': iconCodePoint,
      'is_protected': isProtected ? 1 : 0,
      'parent_category_id': parentCategoryId,
    };
  }
}

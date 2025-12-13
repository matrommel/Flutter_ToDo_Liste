// Domain Layer - Geschäftslogik
// Diese Klasse repräsentiert eine Kategorie ohne DB-Abhängigkeiten

import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final int? id;
  final String name;
  final DateTime createdAt;
  final int order;
  final int? iconCodePoint;

  const Category({
    this.id,
    required this.name,
    required this.createdAt,
    this.order = 0,
    this.iconCodePoint,
  });

  @override
  List<Object?> get props => [id, name, createdAt, order, iconCodePoint];
}

// Mock-Generierung für Tests
// Führe aus: flutter pub run build_runner build

import 'package:matzo/domain/repositories/category_repository.dart';
import 'package:matzo/domain/repositories/todo_item_repository.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([
  CategoryRepository,
  TodoItemRepository,
])
void main() {}

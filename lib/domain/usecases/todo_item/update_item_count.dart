// Domain Layer - Use Case für das Ändern der Anzahl eines Items

import 'package:matzo/domain/repositories/todo_item_repository.dart';

class UpdateItemCount {
  final TodoItemRepository repository;

  UpdateItemCount(this.repository);

  Future<void> call(int itemId, int newCount) async {
    // Validierung
    if (newCount < 1) {
      throw Exception('Anzahl muss mindestens 1 sein');
    }

    await repository.updateItemCount(itemId, newCount);
  }
}

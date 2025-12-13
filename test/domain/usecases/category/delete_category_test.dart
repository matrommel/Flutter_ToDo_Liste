import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:matzo/domain/repositories/category_repository.dart';
import 'package:matzo/domain/usecases/category/delete_category.dart';

import 'delete_category_test.mocks.dart';

@GenerateMocks([CategoryRepository])
void main() {
  late DeleteCategory useCase;
  late MockCategoryRepository mockRepository;

  setUp(() {
    mockRepository = MockCategoryRepository();
    useCase = DeleteCategory(mockRepository);
  });

  group('DeleteCategory UseCase', () {
    const testCategoryId = 1;

    test('sollte Kategorie erfolgreich löschen', () async {
      // Arrange
      when(mockRepository.deleteCategory(testCategoryId))
          .thenAnswer((_) async => Future.value());

      // Act
      await useCase(testCategoryId);

      // Assert
      verify(mockRepository.deleteCategory(testCategoryId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('sollte Exception weitergeben bei Fehler', () async {
      // Arrange
      when(mockRepository.deleteCategory(testCategoryId))
          .thenThrow(Exception('Database error'));

      // Act & Assert
      expect(
        () => useCase(testCategoryId),
        throwsA(isA<Exception>()),
      );
      verify(mockRepository.deleteCategory(testCategoryId)).called(1);
    });

    test('sollte mit verschiedenen IDs funktionieren', () async {
      // Arrange
      const ids = [1, 5, 100, 999];
      when(mockRepository.deleteCategory(any))
          .thenAnswer((_) async => Future.value());

      // Act & Assert
      for (final id in ids) {
        await useCase(id);
        verify(mockRepository.deleteCategory(id)).called(1);
      }
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:matzo/domain/entities/category.dart';
import 'package:matzo/domain/repositories/category_repository.dart';
import 'package:matzo/domain/usecases/category/get_categories.dart';

import 'get_categories_test.mocks.dart';

@GenerateMocks([CategoryRepository])
void main() {
  late GetCategories useCase;
  late MockCategoryRepository mockRepository;

  setUp(() {
    mockRepository = MockCategoryRepository();
    useCase = GetCategories(mockRepository);
  });

  group('GetCategories UseCase', () {
    final testCategories = [
      Category(
        id: 1,
        name: 'Einkaufen',
        createdAt: DateTime(2024, 1, 1),
        order: 0,
      ),
      Category(
        id: 2,
        name: 'Arbeit',
        createdAt: DateTime(2024, 1, 2),
        order: 1,
      ),
      Category(
        id: 3,
        name: 'Haushalt',
        createdAt: DateTime(2024, 1, 3),
        order: 2,
      ),
    ];

    test('sollte Liste von Kategorien zurückgeben', () async {
      // Arrange
        when(mockRepository.getAllCategories())
          .thenAnswer((_) async => testCategories);

      // Act
      final result = await useCase();

      // Assert
      expect(result, testCategories);
      expect(result.length, 3);
      verify(mockRepository.getAllCategories()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('sollte leere Liste zurückgeben wenn keine Kategorien existieren', () async {
      // Arrange
        when(mockRepository.getAllCategories())
          .thenAnswer((_) async => []);

      // Act
      final result = await useCase();

      // Assert
      expect(result, isEmpty);
      verify(mockRepository.getAllCategories()).called(1);
    });

    test('sollte Exception weitergeben bei Fehler', () async {
      // Arrange
        when(mockRepository.getAllCategories())
          .thenThrow(Exception('Database error'));

      // Act & Assert
      expect(
        () => useCase(),
        throwsA(isA<Exception>()),
      );
      verify(mockRepository.getAllCategories()).called(1);
    });

    test('sollte Kategorien in korrekter Reihenfolge zurückgeben', () async {
      // Arrange
        when(mockRepository.getAllCategories())
          .thenAnswer((_) async => testCategories);

      // Act
      final result = await useCase();

      // Assert
      expect(result[0].name, 'Einkaufen');
      expect(result[1].name, 'Arbeit');
      expect(result[2].name, 'Haushalt');
    });
  });
}

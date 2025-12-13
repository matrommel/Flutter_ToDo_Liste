import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:matzo/domain/entities/category.dart';
import 'package:matzo/domain/repositories/category_repository.dart';
import 'package:matzo/domain/usecases/category/add_category.dart';

import 'add_category_test.mocks.dart';

@GenerateMocks([CategoryRepository])
void main() {
  late AddCategory useCase;
  late MockCategoryRepository mockRepository;

  setUp(() {
    mockRepository = MockCategoryRepository();
    useCase = AddCategory(mockRepository);
  });

  group('AddCategory UseCase', () {
    const testName = 'Einkaufen';

    test('sollte Kategorie erfolgreich hinzufügen mit korrektem Namen', () async {
      // Arrange
        when(mockRepository.addCategory(any)).thenAnswer((_) async => 1);

      // Act
      final result = await useCase(testName, iconCodePoint: null);

      // Assert
      expect(result, 1);
      verify(mockRepository.addCategory(
        argThat(predicate<Category>((cat) =>
            cat.name == testName && cat.iconCodePoint == null)),
      )).called(1);
    });

    test('sollte Whitespace trimmen', () async {
      const nameWithSpaces = '  Einkaufen  ';
        when(mockRepository.addCategory(any)).thenAnswer((_) async => 1);

      // Act
      await useCase(nameWithSpaces, iconCodePoint: null);

      // Assert
      verify(mockRepository.addCategory(
        argThat(predicate<Category>((cat) =>
            cat.name == 'Einkaufen' && cat.iconCodePoint == null)),
      )).called(1);
    });

    test('sollte Exception werfen bei leerem Namen', () async {
      // Act & Assert
      expect(
        () => useCase('', iconCodePoint: null),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('darf nicht leer sein'),
          ),
        ),
      );
      verifyNever(mockRepository.addCategory(any));
    });

    test('sollte Exception werfen bei nur Whitespace', () async {
      // Act & Assert
      expect(
        () => useCase('   ', iconCodePoint: null),
        throwsA(isA<Exception>()),
      );
      verifyNever(mockRepository.addCategory(any));
    });

    test('sollte Exception werfen bei zu langem Namen (>50 Zeichen)', () async {
      // Arrange
      final longName = 'a' * 51;

      // Act & Assert
      expect(
        () => useCase(longName, iconCodePoint: null),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('maximal 50 Zeichen'),
          ),
        ),
      );
      verifyNever(mockRepository.addCategory(any));
    });

    test('sollte Namen mit genau 50 Zeichen akzeptieren', () async {
      // Arrange
      final maxLengthName = 'a' * 50;
        when(mockRepository.addCategory(any)).thenAnswer((_) async => 1);

      // Act
      await useCase(maxLengthName, iconCodePoint: null);

      // Assert
      verify(mockRepository.addCategory(any)).called(1);
    });

    test('sollte Sonderzeichen im Namen erlauben', () async {
      // Arrange
      const specialName = 'Einkauf & Haushalt (wichtig!)';
        when(mockRepository.addCategory(any)).thenAnswer((_) async => 1);

      // Act
      await useCase(specialName, iconCodePoint: null);

      // Assert
      verify(mockRepository.addCategory(
        argThat(predicate<Category>((cat) =>
            cat.name == specialName && cat.iconCodePoint == null)),
      )).called(1);
    });
  });
}

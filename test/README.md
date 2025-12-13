# Tests für Flutter Todo App 🧪

Dieses Dokument beschreibt die Test-Strategie und wie du die Tests ausführst.

## Test-Struktur

```
test/
├── domain/
│   └── usecases/
│       ├── category/
│       │   ├── add_category_test.dart
│       │   ├── delete_category_test.dart
│       │   └── get_categories_test.dart
│       ├── todo_item/
│       │   ├── add_todo_item_test.dart
│       │   ├── delete_todo_item_test.dart
│       │   ├── edit_todo_item_test.dart
│       │   ├── get_todo_items_test.dart
│       │   ├── toggle_todo_item_test.dart
│       │   ├── update_item_count_test.dart
│       │   └── update_todo_item_test.dart
│       └── search/
│           └── search_todo_items_test.dart
├── presentation/
│   ├── home/
│   │   └── bloc/
│   │       └── home_cubit_test.dart
│   └── category/
│       └── bloc/
│           └── category_cubit_test.dart
└── helpers/
    └── test_helper.dart
```

## Test-Arten

### 1. Unit Tests
- **Ort**: `test/domain/usecases/`
- **Was**: UseCases (Geschäftslogik)
- **Anzahl**: 50+ Tests
- **Abdeckung**: ~100% der UseCases

### 2. BLoC Tests
- **Ort**: `test/presentation/*/bloc/`
- **Was**: Cubit State Management
- **Anzahl**: 20+ Tests
- **Abdeckung**: ~90% der Cubits

## Tests ausführen

### Alle Tests ausführen
```bash
flutter test
```

### Einzelne Test-Datei
```bash
flutter test test/domain/usecases/category/add_category_test.dart
```

### Tests mit Code Coverage
```bash
flutter test --coverage
```

### Coverage Report anzeigen
```bash
# HTML Report generieren
genhtml coverage/lcov.info -o coverage/html

# Report öffnen (macOS)
open coverage/html/index.html

# Report öffnen (Linux)
xdg-open coverage/html/index.html

# Report öffnen (Windows)
start coverage/html/index.html
```

### Mocks generieren
Wenn du neue Tests mit Mocks erstellst:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Test-Abdeckung Ziele

- ✅ **UseCases**: 100%
- ✅ **BLoCs/Cubits**: 90%+
- 🎯 **Gesamt**: 70%+

## Aktuelle Test-Übersicht

### Category UseCases
- ✅ `add_category_test.dart` (7 Tests)
- ✅ `delete_category_test.dart` (3 Tests)
- ✅ `get_categories_test.dart` (4 Tests)

### TodoItem UseCases
- ✅ `add_todo_item_test.dart` (8 Tests)
- ✅ `delete_todo_item_test.dart` (3 Tests)
- ✅ `edit_todo_item_test.dart` (6 Tests)
- ✅ `get_todo_items_test.dart` (5 Tests)
- ✅ `toggle_todo_item_test.dart` (4 Tests)
- ✅ `update_item_count_test.dart` (5 Tests)
- ✅ `update_todo_item_test.dart` (13 Tests)

### BLoC/Cubit Tests
- ✅ `home_cubit_test.dart` (5 Tests)
- ✅ `category_cubit_test.dart` (12 Tests)

### Search
- ✅ `search_todo_items_test.dart` (5 Tests)

**Gesamt: 78+ Tests**

## Best Practices

### 1. Test-Struktur (AAA Pattern)
```dart
test('sollte...', () async {
  // Arrange - Setup
  when(mockRepository.someMethod())
      .thenAnswer((_) async => expectedResult);

  // Act - Ausführen
  final result = await useCase();

  // Assert - Überprüfen
  expect(result, expectedResult);
  verify(mockRepository.someMethod()).called(1);
});
```

### 2. Beschreibende Test-Namen
✅ Gut: `sollte Exception werfen bei leerem Namen`
❌ Schlecht: `test1`, `error test`

### 3. Test Isolation
- Jeder Test ist unabhängig
- Keine gemeinsamen States
- `setUp()` und `tearDown()` nutzen

### 4. Edge Cases testen
- Leere Eingaben
- Maximale Werte
- Grenzwerte
- Fehler-Szenarien

## Continuous Integration

Für CI/CD Pipeline (z.B. GitHub Actions):

```yaml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v2
```

## Neue Tests hinzufügen

1. **UseCase Test erstellen**:
```dart
// test/domain/usecases/my_new_usecase_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([MyRepository])
import 'my_new_usecase_test.mocks.dart';

void main() {
  late MyNewUseCase useCase;
  late MockMyRepository mockRepository;

  setUp(() {
    mockRepository = MockMyRepository();
    useCase = MyNewUseCase(mockRepository);
  });

  group('MyNewUseCase', () {
    test('sollte...', () async {
      // Test implementation
    });
  });
}
```

2. **Mocks generieren**:
```bash
flutter pub run build_runner build
```

3. **Test ausführen**:
```bash
flutter test test/domain/usecases/my_new_usecase_test.dart
```

## Troubleshooting

### Problem: Mock-Dateien fehlen
**Lösung**: 
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Problem: Tests schlagen fehl
**Lösung**:
1. Prüfe ob Dependencies aktuell sind: `flutter pub get`
2. Lösche Build-Cache: `flutter clean`
3. Mocks neu generieren

### Problem: Coverage-Report fehlt
**Lösung**:
```bash
# Installiere lcov (Linux/macOS)
sudo apt-get install lcov  # Linux
brew install lcov          # macOS

# Generiere Report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## Nützliche Commands

```bash
# Nur Unit Tests
flutter test test/domain/

# Nur BLoC Tests
flutter test test/presentation/

# Watch Mode (bei Änderungen neu ausführen)
flutter test --watch

# Verbose Output
flutter test --verbose

# Parallele Ausführung
flutter test --concurrency=4
```

---

Happy Testing! 🎉

# 🧪 Test-Dokumentation

## Übersicht

Die App enthält umfangreiche Unit Tests für alle wichtigen Komponenten nach der Test-Pyramide:

```
Test-Abdeckung:
├── Unit Tests (70%)        ← Domain Layer (UseCases, Entities)
├── BLoC Tests (20%)        ← Presentation Layer (State Management)
└── Widget Tests (10%)      ← UI-Komponenten
```

## Test-Setup

### 1. Dependencies installieren

```bash
flutter pub get
```

### 2. Mocks generieren

Die Tests verwenden Mockito für Mocking. Mocks müssen vor dem ersten Test-Lauf generiert werden:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Tests ausführen

**Alle Tests:**
```bash
flutter test
```

**Einzelnen Test:**
```bash
flutter test test/domain/usecases/category/add_category_test.dart
```

**Mit Coverage:**
```bash
flutter test --coverage
```

**Automatisches Skript:**
```bash
./run_tests.sh
```

## Test-Struktur

```
test/
├── domain/
│   └── usecases/
│       ├── category/
│       │   ├── add_category_test.dart
│       │   └── ...
│       ├── todo_item/
│       │   ├── add_todo_item_test.dart
│       │   ├── edit_todo_item_test.dart      ← NEU!
│       │   ├── toggle_todo_item_test.dart
│       │   ├── update_item_count_test.dart
│       │   ├── get_todo_items_test.dart
│       │   └── ...
│       └── search/
│           └── search_todo_items_test.dart    ← NEU!
└── presentation/
    └── home/
        └── bloc/
            └── home_cubit_test.dart
```

## Implementierte Tests

### ✅ Domain Layer - UseCases

#### **AddCategory** (7 Tests)
- ✓ Kategorie erfolgreich hinzufügen
- ✓ Whitespace trimmen
- ✓ Exception bei leerem Namen
- ✓ Exception bei nur Whitespace
- ✓ Exception bei zu langem Namen (>50 Zeichen)
- ✓ Maximale Länge akzeptieren (50 Zeichen)
- ✓ Sonderzeichen erlauben

#### **AddTodoItem** (7 Tests)
- ✓ Item erfolgreich hinzufügen
- ✓ Whitespace trimmen
- ✓ Exception bei leerem Titel
- ✓ Exception bei zu langem Titel (>100 Zeichen)
- ✓ Maximale Länge akzeptieren
- ✓ Count standardmäßig auf 1 setzen
- ✓ isCompleted standardmäßig auf false setzen

#### **ToggleTodoItem** (4 Tests)
- ✓ Nicht-erledigtes Item als erledigt markieren
- ✓ Erledigtes Item als nicht-erledigt markieren
- ✓ completedAt beim Erledigen setzen
- ✓ Andere Felder unverändert lassen

#### **EditTodoItem** (7 Tests) 🆕
- ✓ Item-Titel erfolgreich aktualisieren
- ✓ Whitespace trimmen
- ✓ Exception bei leerem Titel
- ✓ Exception bei nur Whitespace
- ✓ Exception bei zu langem Titel
- ✓ Andere Felder unverändert lassen
- ✓ Sonderzeichen erlauben

#### **UpdateItemCount** (7 Tests)
- ✓ Anzahl erhöhen
- ✓ Anzahl verringern
- ✓ Anzahl von 1 akzeptieren
- ✓ Exception bei Anzahl < 1
- ✓ Exception bei negativer Anzahl
- ✓ Andere Felder unverändert lassen
- ✓ Große Anzahlen akzeptieren

#### **GetTodoItems** (8 Tests)
- ✓ Items für Kategorie abrufen
- ✓ Offene Items alphabetisch sortieren
- ✓ Erledigte Items alphabetisch sortieren
- ✓ Offene vor erledigten Items
- ✓ Groß-/Kleinschreibung ignorieren
- ✓ Leere Liste bei keinen Items
- ✓ Gemischte Items korrekt sortieren
- ✓ Komplexe Sortierung testen

#### **SearchTodoItems** (11 Tests) 🆕
- ✓ Items nach Titel finden
- ✓ Items nach Kategorie-Namen finden
- ✓ Groß-/Kleinschreibung ignorieren
- ✓ Teilstrings finden
- ✓ Leere Liste bei leerem Query
- ✓ Leere Liste bei nur Whitespace
- ✓ Whitespace trimmen
- ✓ Leere Liste bei keinen Treffern
- ✓ Über mehrere Kategorien suchen
- ✓ Erledigte Items finden
- ✓ Mehrere Treffer korrekt zurückgeben

**Gesamt: 58 Unit Tests**

### ✅ Presentation Layer - BLoCs

#### **HomeCubit** (7 Tests)
- ✓ Initialer State ist HomeInitial
- ✓ Kategorien erfolgreich laden
- ✓ HomeError bei Fehler
- ✓ Neue Kategorie hinzufügen
- ✓ Kategorie löschen
- ✓ Fehler handhaben und neu laden
- ✓ Leere Liste korrekt handhaben

## Neue Features getestet

### 1. ✏️ Item-Bearbeitung
- **UseCase**: EditTodoItem
- **Tests**: 7 umfangreiche Tests
- **Validierung**: Titel-Länge, Whitespace, Sonderzeichen

### 2. 🔍 Suche & Filter
- **UseCase**: SearchTodoItems
- **Tests**: 11 umfangreiche Tests
- **Features**: 
  - Suche über alle Kategorien
  - Titel- und Kategorie-Suche
  - Groß-/Kleinschreibung ignorieren
  - Teilstring-Matching

### 3. 🔄 Sortierung
- **UseCase**: GetTodoItems (erweitert)
- **Tests**: 8 Tests für Sortierung
- **Features**:
  - Alphabetische Sortierung
  - Offene Items zuerst
  - Case-insensitive

## Test-Patterns & Best Practices

### Mockito Annotations
```dart
@GenerateMocks([CategoryRepository])
void main() {
  late AddCategory useCase;
  late MockCategoryRepository mockRepository;
  
  setUp(() {
    mockRepository = MockCategoryRepository();
    useCase = AddCategory(mockRepository);
  });
}
```

### bloc_test Pattern
```dart
blocTest<HomeCubit, HomeState>(
  'sollte Kategorien laden',
  build: () {
    when(mockGetCategories()).thenAnswer((_) async => categories);
    return cubit;
  },
  act: (cubit) => cubit.loadCategories(),
  expect: () => [
    HomeLoading(),
    isA<HomeLoaded>(),
  ],
);
```

### Arrange-Act-Assert
```dart
test('sollte Kategorie hinzufügen', () async {
  // Arrange
  when(mockRepository.addCategory(any))
      .thenAnswer((_) async => 1);

  // Act
  final result = await useCase('Test');

  // Assert
  expect(result, 1);
  verify(mockRepository.addCategory(any)).called(1);
});
```

## Code Coverage

Nach dem Ausführen von Tests mit Coverage:

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html  # macOS
```

**Ziel-Coverage:**
- UseCases: 100%
- BLoCs: 90%+
- Repositories: 80%+
- Gesamt: 70%+

## Häufige Probleme

### Mocks nicht gefunden
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Tests schlagen fehl
1. Dependencies aktualisieren: `flutter pub get`
2. Mocks neu generieren
3. Flutter clean: `flutter clean`

### Coverage funktioniert nicht
- lcov installieren (Linux): `sudo apt-get install lcov`
- macOS: `brew install lcov`

## Weitere Tests hinzufügen

### 1. Neue UseCase testen

```dart
// test/domain/usecases/my_usecase_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([MyRepository])
void main() {
  late MyUseCase useCase;
  late MockMyRepository mockRepository;

  setUp(() {
    mockRepository = MockMyRepository();
    useCase = MyUseCase(mockRepository);
  });

  test('sollte funktionieren', () async {
    // Test implementieren
  });
}
```

### 2. Mocks generieren
```bash
flutter pub run build_runner build
```

### 3. Test ausführen
```bash
flutter test test/domain/usecases/my_usecase_test.dart
```

## CI/CD Integration

### GitHub Actions Beispiel
```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter pub run build_runner build
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v3
```

## Nächste Schritte

- [ ] Integration Tests hinzufügen
- [ ] Widget Tests für UI-Komponenten
- [ ] Golden Tests für visuelle Regression
- [ ] Performance Tests

## Hilfe & Ressourcen

- [Flutter Testing Docs](https://docs.flutter.dev/testing)
- [Mockito Dokumentation](https://pub.dev/packages/mockito)
- [bloc_test Dokumentation](https://pub.dev/packages/bloc_test)

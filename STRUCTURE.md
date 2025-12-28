# Flutter Todo App - Projektstruktur

```
matzo/
│
├── lib/                                    # Haupt-Source-Code
│   ├── main.dart                          # App-Einstiegspunkt
│   │
│   ├── core/                              # Kern-Funktionalität
│   │   ├── di/
│   │   │   └── injection.dart             # Dependency Injection Setup
│   │   └── theme/
│   │       └── app_theme.dart             # App-Design (Light/Dark Theme)
│   │
│   ├── data/                              # Data Layer
│   │   ├── datasources/
│   │   │   └── local/
│   │   │       ├── database_helper.dart   # SQLite Datenbank
│   │   │       ├── category_local_datasource.dart
│   │   │       └── todo_item_local_datasource.dart
│   │   ├── models/
│   │   │   ├── category_model.dart        # Kategorie DB-Model
│   │   │   └── todo_item_model.dart       # TodoItem DB-Model
│   │   └── repositories/
│   │       ├── category_repository_impl.dart
│   │       └── todo_item_repository_impl.dart
│   │
│   ├── domain/                            # Domain Layer (Geschäftslogik)
│   │   ├── entities/
│   │   │   ├── category.dart              # Kategorie Entity
│   │   │   └── todo_item.dart             # TodoItem Entity
│   │   ├── repositories/
│   │   │   ├── category_repository.dart   # Repository Interface
│   │   │   └── todo_item_repository.dart  # Repository Interface
│   │   └── usecases/
│   │       ├── category/
│   │       │   ├── get_categories.dart
│   │       │   ├── add_category.dart
│   │       │   ├── delete_category.dart
│   │       │   └── get_category_item_count.dart
│   │       └── todo_item/
│   │           ├── get_todo_items.dart
│   │           ├── add_todo_item.dart
│   │           ├── toggle_todo_item.dart
│   │           ├── update_item_count.dart
│   │           └── delete_todo_item.dart
│   │
│   └── presentation/                      # Presentation Layer (UI)
│       ├── widgets/                       # Shared Widgets
│       │   ├── category_options_dialog.dart  # Unified Options Dialog (Categories & Subcategories)
│       │   └── edit_category_dialog.dart     # Unified Edit Dialog (Categories & Subcategories)
│       ├── home/                          # Home Screen (Kategorien)
│       │   ├── bloc/
│       │   │   ├── home_cubit.dart       # State Management
│       │   │   └── home_state.dart       # UI States
│       │   ├── widgets/
│       │   │   ├── category_card.dart    # Kategorie-Karte Widget
│       │   │   └── biometric_protection_dialog.dart  # Biometric Protection Dialog
│       │   └── home_screen.dart          # Home Screen
│       ├── category/                      # Category Screen (Items)
│       │   ├── bloc/
│       │   │   ├── category_cubit.dart   # State Management
│       │   │   └── category_state.dart   # UI States
│       │   ├── widgets/
│       │   │   ├── todo_item_tile.dart   # Item Widget
│       │   │   ├── add_item_dialog.dart  # Dialog zum Hinzufügen
│       │   │   ├── edit_item_dialog.dart # Dialog zum Bearbeiten
│       │   │   └── subcategory_tile.dart # Subcategory Widget
│       │   └── category_screen.dart      # Category Screen
│       └── settings/                      # Settings Screen
│           └── settings_screen.dart      # Settings Screen
│
├── pubspec.yaml                           # Dependencies & Projekt-Config
├── analysis_options.yaml                  # Lint-Regeln
├── .gitignore                            # Git Ignore-Datei
│
├── README.md                             # Vollständige Dokumentation
├── QUICKSTART.md                         # Schnellstart-Anleitung
└── setup.sh                              # Setup-Script


GESAMTSTATISTIK:
================
📊 35+ Dart-Dateien
📁 3 Layer (Domain, Data, Presentation)
🔧 Clean Architecture Pattern
💾 SQLite Datenbank (Mobile/Desktop) + Web Storage (Browser)
🎨 Material Design 3
🌓 Dark Mode Support
🔒 Biometrische Authentifizierung
📂 Hierarchische Kategorien (Categories & Subcategories)
♻️  Unified Widget Pattern (weniger Code-Duplikation)
```

## Aktuelle Code-Qualität Verbesserungen

### Unified Dialog Widgets
- **CategoryOptionsDialog**: Behandelt Options-Menü für Kategorien UND Unterkategorien
- **EditCategoryDialog**: Behandelt Bearbeitung für Kategorien UND Unterkategorien
- Eliminiert ~735 Zeilen duplizierter Code
- Konsistentes UX für alle Kategorie-Typen
```

## Layer-Übersicht

### 🎯 Domain Layer (Geschäftslogik)
- **Entities**: Reine Business-Objekte ohne Dependencies
- **Use Cases**: Einzelne Geschäftslogik-Operationen
- **Repositories**: Interfaces für Datenzugriff

### 💾 Data Layer (Datenzugriff)
- **Models**: Datenbank-Modelle mit Mapping
- **Data Sources**: Direkter Zugriff auf SQLite
- **Repositories**: Implementierung der Domain-Interfaces

### 🎨 Presentation Layer (UI)
- **Screens**: Hauptbildschirme der App
- **Widgets**: Wiederverwendbare UI-Komponenten
- **BLoC/Cubit**: State Management mit Business Logic Component

## Datenfluss

```
User Interaction (UI)
        ↓
   Cubit/BLoC
        ↓
    Use Case
        ↓
   Repository Interface
        ↓
Repository Implementation
        ↓
   Data Source
        ↓
    Database
```

## Wichtige Dateien

| Datei | Beschreibung |
|-------|--------------|
| `main.dart` | App-Einstiegspunkt, initialisiert DI |
| `injection.dart` | Dependency Injection Setup |
| `database_helper.dart` | SQLite Datenbank-Konfiguration |
| `home_screen.dart` | Kategorien-Übersicht |
| `category_screen.dart` | Todo-Items einer Kategorie |

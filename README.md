# Matzo

Moderne ToDo-App mit Kategorien, Undo-Snackbars, Vorschlagschips und manueller Sortierung.

## Hauptfunktionen
- Kategorien mit wählbaren Standard-Material-Icons.
- Items hinzufügen mit Vorschlags-Chips (aus erledigten Items) und automatischem Merge: gleicher Titel erhöht den Zähler statt Duplikat.
- Offene Items per Drag & Drop umsortieren; Sortierung auf-/absteigend umschaltbar.
- „Abgehakte Items ausblenden“ pro Kategorie toggelbar.
- Snackbars mit Rückgängig für Toggle/Delete.

## Entwicklung
```bash
flutter pub get
flutter run
# Tests (falls lauffähig)
flutter test
```

## Hinweise
- Build-Artefakte und Plattform-Outputs sind via `.gitignore` ausgeschlossen (`build/`, `*.apk`, `*.aab`, `*.ipa`, `*.xcarchive`, SQLite-DBs, IDE-Ordner).
- Datenbank-Version 3: `categories.icon_code`, `todo_items.order_num` für Icon- und Reihenfolge-Support.

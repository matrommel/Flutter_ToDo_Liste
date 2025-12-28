# Matzo

Moderne ToDo-App mit Kategorien, Unterkategorien, Biometrischer Authentifizierung, Vorschlagschips und manueller Sortierung.

## Hauptfunktionen

### Kategorie-Management
- **Hierarchische Kategorien**: Kategorien und Unterkategorien für bessere Organisation
- Kategorien mit wählbaren Standard-Material-Icons oder eigenen Emojis
- **Biometrischer Schutz**: Kategorien mit Fingerabdruck/Face ID schützen (lange Taste auf Kategorie)
- Kategorien manuell per Drag & Drop umsortieren
- Fortschrittsbalken auf jeder Kategorie-Karte

### Item-Management
- **Items bearbeiten**: Name und Anzahl ändern
- **Intelligente Vorschläge**: Dynamische Suggestion-Chips beim Hinzufügen zeigen bereits erledigte Items
- **Automatisches Merge**: Gleicher Titel erhöht den Zähler statt Duplikat zu erstellen
- **Manuelle Sortierung**: Offene Items per Drag & Drop umsortieren
- **Flexible Ansichten**: Sortierung aufsteigend/absteigend umschaltbar, erledigte Items ausblenden
- **Item-Anzahl**: Schnell erhöhen/verringern mit +/- Buttons
- **Link-Unterstützung**: URLs in Item-Beschreibungen werden automatisch erkannt und klickbar gemacht

### Sicherheit
- **Biometrische Authentifizierung** für ausgewählte Kategorien
- Fingerabdruck (Android & iOS)
- Face ID (iOS)
- Automatische Fallback-Abfrage wenn Biometrie nicht verfügbar

## Entwicklung
```bash
# Abhängigkeiten installieren
flutter pub get

# App starten
flutter run

# Analyser & Tests
flutter analyze
flutter test
```

## Neueste Updates (Dezember 2025)

### Code-Qualität Verbesserungen
- **Unified Dialog Widgets**: Kategorien und Unterkategorien verwenden jetzt dieselben Dialog-Widgets
- **~735 Zeilen Duplikat-Code eliminiert** durch Refactoring
- Neue Widgets: `CategoryOptionsDialog` und `EditCategoryDialog`
- Konsistente User Experience für alle Kategorie-Typen

Siehe [UPDATE_NOTES.md](UPDATE_NOTES.md) für Details.

## Technologie-Stack
- **Frontend**: Flutter 3.0+, Bloc/Cubit für State Management
- **Authentifizierung**: local_auth Package (Biometrische Auth)
- **Datenbank**: SQLite mit sqflite (Mobile/Desktop), Web Storage (Browser)
- **Architektur**: Clean Architecture (Presentation → Domain → Data)
- **Code-Qualität**: Unified Widget Pattern für weniger Code-Duplikation
- **UI**: Material Design 3 mit Dark Mode Support

## Datenbank
- **Version 5** (aktuell):
  - `categories.icon_code` - Icon/Emoji für Kategorie
  - `categories.is_protected` - Biometrischer Schutz aktiviert
  - `categories.parent_category_id` - Für Unterkategorien (NULL = Top-Level)
  - `todo_items.order_num` - Manuelle Sortierung
  - `todo_items.description` - Beschreibung mit Link-Unterstützung

## Native Konfiguration

### Android
- `android/app/src/main/AndroidManifest.xml`: 
  - `android.permission.USE_BIOMETRIC`
  - `android.permission.USE_FINGERPRINT`

### iOS
- `ios/Runner/Info.plist`:
  - `NSFaceIDUsageDescription` - Beschreibung für Face ID Permission

## Hinweise
- Build-Artefakte und Plattform-Outputs sind via `.gitignore` ausgeschlossen (`build/`, `*.apk`, `*.aab`, `*.ipa`, `*.xcarchive`, SQLite-DBs, IDE-Ordner)
- Datenbank wird automatisch bei Versionswechsel migriert
- Biometrische Auth prüft Gerätekompatibilität vor Authentifizierung
- **Web-Unterstützung**: App läuft auch im Browser mit angepasstem Storage
- **Unified Widgets**: Kategorien und Unterkategorien teilen sich dieselbe Dialog-Logik für einfachere Wartung

## Weitere Dokumentation
- [QUICKSTART.md](QUICKSTART.md) - Schnellstart-Anleitung
- [FEATURES.md](FEATURES.md) - Detaillierte Feature-Übersicht
- [STRUCTURE.md](STRUCTURE.md) - Projektstruktur
- [UPDATE_NOTES.md](UPDATE_NOTES.md) - Changelog und Updates

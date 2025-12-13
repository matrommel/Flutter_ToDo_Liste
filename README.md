# Matzo

Moderne ToDo-App mit Kategorien, Biometrischer Authentifizierung, Vorschlagschips und manueller Sortierung.

## Hauptfunktionen

### Kategorie-Management
- Kategorien mit wählbaren Standard-Material-Icons
- **Biometrischer Schutz**: Kategorien mit Fingerabdruck/Face ID schützen (lange Taste auf Kategorie)
- Kategorien manuell per Drag & Drop umsortieren

### Item-Management
- Items hinzufügen mit dynamischen Vorschlags-Chips (aus erledigten Items)
- Automatisches Merge: Gleicher Titel erhöht den Zähler statt Duplikat zu erstellen
- Offene Items per Drag & Drop umsortieren
- Sortierung aufsteigend/absteigend umschaltbar
- „Abgehakte Items ausblenden" pro Kategorie toggelbar
- Item-Anzahl erhöhen/verringern

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

## Technologie-Stack
- **Frontend**: Flutter 3.0+, Bloc/Cubit für State Management
- **Authentifizierung**: local_auth Package (Biometrische Auth)
- **Datenbank**: SQLite mit sqflite
- **Architektur**: Clean Architecture (Presentation → Domain → Data)

## Datenbank
- **Version 4**: 
  - `categories.icon_code` - Icon für Kategorie
  - `categories.is_protected` - Biometrischer Schutz aktiviert
  - `todo_items.order_num` - Manuelle Sortierung

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

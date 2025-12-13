# 🚀 Quickstart Guide

## Schnelle Installation (5 Minuten)

### 1. Flutter installieren

**Windows:**
```bash
# Lade Flutter von https://docs.flutter.dev/get-started/install/windows herunter
# Entpacke die ZIP-Datei
# Füge flutter\bin zu deinem PATH hinzu
```

**macOS:**
```bash
# Mit Homebrew:
brew install flutter

# Oder manuell von:
# https://docs.flutter.dev/get-started/install/macos
```

**Linux:**
```bash
# Lade Flutter von https://docs.flutter.dev/get-started/install/linux herunter
sudo snap install flutter --classic
```

### 2. Flutter prüfen

```bash
flutter doctor
```

Du solltest mindestens einen grünen Haken bei "Flutter" sehen.

### 3. Projekt Setup

```bash
# Wechsle ins Projekt-Verzeichnis
cd flutter_todo_app

# Installiere Dependencies
flutter pub get
```

Oder nutze das Setup-Script:
```bash
./setup.sh
```

### 4. App starten

**Option A: Android Emulator**
```bash
# Starte Android Studio -> AVD Manager -> Erstelle/Starte Emulator
# Dann:
flutter run
```

**Option B: Physisches Gerät**
```bash
# Android: USB-Debugging aktivieren
# iOS: Gerät mit Xcode verbinden

flutter devices  # Zeigt verfügbare Geräte
flutter run      # Startet auf dem verbundenen Gerät
```

## Erste Schritte in der App

1. **Kategorie erstellen**: Tippe auf das + Symbol
2. **Items hinzufügen**: Öffne eine Kategorie → Tippe auf +
3. **Items abhaken**: Tippe auf die Checkbox
4. **Anzahl ändern**: Nutze die +/- Buttons
5. **Löschen**: 
   - Kategorie: Long-Press (gedrückt halten)
   - Item: Nach links wischen

## Häufige Probleme

### "No devices found"
```bash
# Für Android Emulator:
flutter emulators                    # Zeigt verfügbare Emulatoren
flutter emulators --launch <name>    # Startet einen Emulator

# Für physisches Gerät:
# Android: USB-Debugging in Entwickleroptionen aktivieren
# iOS: Gerät in Xcode hinzufügen
```

### "Gradle build failed" (Android)
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### "CocoaPods not installed" (iOS)
```bash
sudo gem install cocoapods
cd ios
pod install
cd ..
flutter run
```

## Projekt-Struktur (Kurzübersicht)

```
lib/
├── main.dart                    # App-Start
├── core/                        # Kernfunktionalität
│   ├── di/                      # Dependency Injection
│   └── theme/                   # Design
├── data/                        # Datenzugriff
│   ├── datasources/            # Datenbank
│   ├── models/                 # Datenmodelle
│   └── repositories/           # Repository-Implementierung
├── domain/                      # Geschäftslogik
│   ├── entities/               # Business Objects
│   ├── repositories/           # Repository-Interfaces
│   └── usecases/               # Use Cases
└── presentation/                # UI
    ├── home/                   # Kategorien-Screen
    └── category/               # Items-Screen
```

## Nächste Schritte

- 📖 Lies die [vollständige README](README.md) für Details
- 🎨 Passe das Theme in `lib/core/theme/app_theme.dart` an
- 🔧 Erweitere die App mit eigenen Features
- 📱 Baue eine Release-Version mit `flutter build apk`

## Support

Bei Problemen:
1. Führe `flutter doctor -v` aus
2. Prüfe die Flutter-Installation
3. Suche in der [Flutter-Dokumentation](https://docs.flutter.dev)
4. Frage in der [Flutter-Community](https://flutter.dev/community)

Viel Erfolg! 🎉

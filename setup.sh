#!/bin/bash

# Flutter Todo App - Setup Script
# Dieses Script hilft bei der initialen Einrichtung des Projekts

echo "🚀 Flutter Todo App - Setup"
echo "============================"
echo ""

# Prüfe ob Flutter installiert ist
if ! command -v flutter &> /dev/null
then
    echo "❌ Flutter ist nicht installiert!"
    echo "Bitte installiere Flutter von: https://docs.flutter.dev/get-started/install"
    exit 1
fi

echo "✅ Flutter gefunden: $(flutter --version | head -n 1)"
echo ""

# Flutter Doctor ausführen
echo "📋 Führe Flutter Doctor aus..."
flutter doctor
echo ""

# Dependencies installieren
echo "📦 Installiere Dependencies..."
flutter pub get

if [ $? -eq 0 ]; then
    echo "✅ Dependencies erfolgreich installiert"
else
    echo "❌ Fehler beim Installieren der Dependencies"
    exit 1
fi

echo ""
echo "🎉 Setup abgeschlossen!"
echo ""
echo "Nächste Schritte:"
echo "1. Verbinde ein Android-Gerät oder starte einen Emulator"
echo "2. Führe 'flutter devices' aus, um verfügbare Geräte zu sehen"
echo "3. Starte die App mit 'flutter run'"
echo ""

#!/bin/bash

echo "🧪 Flutter Todo App - Test Suite"
echo "================================="
echo ""

# Farben für Output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Mocks generieren
echo -e "${YELLOW}📦 Generiere Mocks...${NC}"
flutter pub run build_runner build --delete-conflicting-outputs

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Mocks erfolgreich generiert${NC}"
else
    echo -e "${RED}❌ Fehler beim Generieren der Mocks${NC}"
    exit 1
fi

echo ""

# Tests ausführen
echo -e "${YELLOW}🧪 Führe Tests aus...${NC}"
flutter test

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ Alle Tests erfolgreich!${NC}"
else
    echo ""
    echo -e "${RED}❌ Einige Tests sind fehlgeschlagen${NC}"
    exit 1
fi

echo ""

# Coverage generieren (optional)
read -p "Möchtest du einen Coverage-Report generieren? (j/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Jj]$ ]]; then
    echo -e "${YELLOW}📊 Generiere Coverage-Report...${NC}"
    flutter test --coverage
    
    if command -v lcov &> /dev/null; then
        genhtml coverage/lcov.info -o coverage/html
        echo -e "${GREEN}✅ Coverage-Report erstellt in coverage/html/index.html${NC}"
        
        # Öffne Report im Browser (macOS/Linux)
        if [[ "$OSTYPE" == "darwin"* ]]; then
            open coverage/html/index.html
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            xdg-open coverage/html/index.html 2>/dev/null
        fi
    else
        echo -e "${YELLOW}⚠️  lcov nicht installiert. Coverage-Daten in coverage/lcov.info${NC}"
    fi
fi

echo ""
echo -e "${GREEN}✨ Test-Durchlauf abgeschlossen!${NC}"

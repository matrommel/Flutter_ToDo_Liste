// Domain Layer - Data Transfer Repository Interface
// Abstrakte Schnittstelle für Export/Import-Operationen

import '../entities/export_data.dart';

/// Repository Interface für Export/Import-Funktionalität
abstract class DataTransferRepository {
  /// Generiert vollständige Export-Daten aus aktueller Datenbank
  /// Enthält alle Kategorien, Unterkategorien und Items
  Future<ExportData> generateExportData();

  /// Importiert Daten mit Merge/Replace-Logik
  /// - deleteExistingData: true = Alle vorhandenen Daten löschen vor Import
  /// - deleteExistingData: false = Daten mergen/hinzufügen
  ///
  /// Returns: Zusammenfassung des Imports (neue/gemergte Kategorien und Items)
  Future<ImportResult> importData({
    required ExportData data,
    required bool deleteExistingData,
  });

  /// Validiert Import-Daten vor dem eigentlichen Import
  /// Prüft JSON-Struktur, Version, Pflichtfelder, etc.
  Future<ValidationResult> validateImportData(ExportData data);
}

/// Result-Klasse für Import-Operationen
/// Enthält Statistik über importierte Daten
class ImportResult {
  final int categoriesAdded;    // Anzahl neu erstellter Kategorien
  final int itemsAdded;          // Anzahl neu erstellter Items
  final int categoriesMerged;    // Anzahl gemergter Kategorien (existierend)

  const ImportResult({
    required this.categoriesAdded,
    required this.itemsAdded,
    required this.categoriesMerged,
  });

  @override
  String toString() {
    return 'ImportResult(categoriesAdded: $categoriesAdded, '
        'itemsAdded: $itemsAdded, categoriesMerged: $categoriesMerged)';
  }
}

/// Result-Klasse für Validierungs-Operationen
/// Gibt an, ob Import-Daten gültig sind
class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  const ValidationResult({
    required this.isValid,
    this.errorMessage,
  });

  /// Factory für erfolgreiche Validierung
  const ValidationResult.valid() : this(isValid: true, errorMessage: null);

  /// Factory für fehlerhafte Validierung
  const ValidationResult.invalid(String message)
      : this(isValid: false, errorMessage: message);

  @override
  String toString() {
    return 'ValidationResult(isValid: $isValid, errorMessage: $errorMessage)';
  }
}

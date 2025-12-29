// Domain Layer - Import Data Use Case
// Koordiniert Import-Prozess mit Validierung

import '../../../domain/entities/export_data.dart';
import '../../../domain/repositories/data_transfer_repository.dart';

/// Use Case für Datenimport
/// Validiert Import-Daten und führt Import durch (All-or-Nothing)
class ImportDataUseCase {
  final DataTransferRepository repository;

  ImportDataUseCase(this.repository);

  /// Führt Import mit Validierung durch
  /// - importData: Zu importierende Daten
  /// - deleteExistingData: true = Alle Daten löschen vor Import
  ///
  /// Throws: Exception bei Validierungsfehlern oder Import-Fehlern
  /// Returns: ImportResult mit Statistik
  Future<ImportResult> call({
    required ExportData importData,
    required bool deleteExistingData,
  }) async {
    // 1. Validiere JSON-Struktur
    final validation = await repository.validateImportData(importData);
    if (!validation.isValid) {
      throw ImportException(
        'Ungültige Import-Datei: ${validation.errorMessage}',
      );
    }

    // 2. Führe Import durch (All-or-Nothing Transaktion)
    try {
      final result = await repository.importData(
        data: importData,
        deleteExistingData: deleteExistingData,
      );

      return result;
    } catch (e) {
      throw ImportException(
        'Import fehlgeschlagen: $e',
      );
    }
  }
}

/// Custom Exception für Import-Fehler
class ImportException implements Exception {
  final String message;

  ImportException(this.message);

  @override
  String toString() => message;
}

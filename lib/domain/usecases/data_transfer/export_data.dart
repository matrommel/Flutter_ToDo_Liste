// Domain Layer - Export Data Use Case
// Koordiniert Export-Prozess und erstellt Filename

import '../../../domain/entities/export_data.dart';
import '../../../domain/repositories/category_repository.dart';
import '../../../domain/repositories/data_transfer_repository.dart';

/// Use Case für Datenexport
/// Generiert Export-Daten und prüft auf geschützte Kategorien
class ExportDataUseCase {
  final DataTransferRepository repository;
  final CategoryRepository categoryRepository;

  ExportDataUseCase(this.repository, this.categoryRepository);

  /// Führt Export durch
  /// Returns: ExportResult mit exportData, filename und hasProtectedCategories
  Future<ExportResult> call() async {
    // 1. Prüfe auf geschützte Kategorien (für UI Biometric-Check)
    final allCategories = await categoryRepository.getAllCategories();
    final hasProtectedCategories = allCategories.any((c) => c.isProtected);

    // 2. Generiere Export-Daten
    final exportData = await repository.generateExportData();

    // 3. Generiere Filename mit Timestamp
    final now = DateTime.now();
    final filename = 'matzo_backup_${_formatDate(now)}.json';

    return ExportResult(
      exportData: exportData,
      filename: filename,
      hasProtectedCategories: hasProtectedCategories,
    );
  }

  /// Formatiert Datum für Filename: YYYY-MM-DD_HH-MM
  String _formatDate(DateTime date) {
    return '${date.year}-${_pad(date.month)}-${_pad(date.day)}_'
        '${_pad(date.hour)}-${_pad(date.minute)}';
  }

  /// Zero-Padding für Zahlen (z.B. 5 → "05")
  String _pad(int value) => value.toString().padLeft(2, '0');
}

/// Result-Klasse für Export-Operationen
class ExportResult {
  final ExportData exportData;
  final String filename;
  final bool hasProtectedCategories;

  const ExportResult({
    required this.exportData,
    required this.filename,
    required this.hasProtectedCategories,
  });
}

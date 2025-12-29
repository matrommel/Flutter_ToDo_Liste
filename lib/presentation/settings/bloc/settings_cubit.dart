// Presentation Layer - Settings Cubit
// State Management für Export/Import-Operationen

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/file_storage_service.dart';
import '../../../data/models/export_data_model.dart';
import '../../../domain/usecases/category/get_categories.dart';
import '../../../domain/usecases/data_transfer/export_data.dart';
import '../../../domain/usecases/data_transfer/import_data.dart';
import 'settings_state.dart';

/// Cubit für Settings-Screen mit Export/Import-Funktionalität
class SettingsCubit extends Cubit<SettingsState> {
  final ExportDataUseCase exportDataUseCase;
  final ImportDataUseCase importDataUseCase;
  final IFileStorageService fileStorageService;
  final GetCategories getCategories;

  SettingsCubit({
    required this.exportDataUseCase,
    required this.importDataUseCase,
    required this.fileStorageService,
    required this.getCategories,
  }) : super(const SettingsInitial());

  /// Prüft ob geschützte Kategorien vorhanden sind
  /// UI nutzt dies für Biometric-Check vor Export
  Future<bool> hasProtectedCategories() async {
    final categories = await getCategories();
    return categories.any((c) => c.isProtected);
  }

  /// Exportiert alle Daten als JSON-Datei
  /// Biometric-Authentifizierung muss vorher durch UI erfolgt sein
  Future<void> exportData() async {
    try {
      emit(const SettingsExporting());

      // 1. Generiere Export-Daten via Use Case
      final result = await exportDataUseCase();

      // 2. Konvertiere zu JSON
      final model = ExportDataModel.fromEntity(result.exportData);
      final jsonString = model.toJsonString();

      // 3. Speichere Datei (plattform-spezifisch)
      await fileStorageService.saveExportFile(jsonString, result.filename);

      emit(SettingsExportSuccess(result.filename));
    } catch (e) {
      emit(SettingsExportError('Export fehlgeschlagen: $e'));
    }
  }

  /// Importiert Daten aus JSON-Datei
  /// - deleteExistingData: true = Alle Daten löschen vor Import
  Future<void> importData({required bool deleteExistingData}) async {
    try {
      emit(const SettingsImporting());

      // 1. Datei auswählen
      final jsonString = await fileStorageService.pickImportFile();
      if (jsonString == null) {
        emit(const SettingsInitial()); // User hat abgebrochen
        return;
      }

      // 2. JSON parsen
      final ExportDataModel importData;
      try {
        importData = ExportDataModel.fromJsonString(jsonString);
      } catch (e) {
        emit(const SettingsImportError(
          'Ungültige JSON-Datei. Bitte wählen Sie eine gültige Backup-Datei.',
        ));
        return;
      }

      // 3. Import durchführen (mit Validierung)
      final result = await importDataUseCase(
        importData: importData,
        deleteExistingData: deleteExistingData,
      );

      emit(SettingsImportSuccess(result));
    } on ImportException catch (e) {
      emit(SettingsImportError(e.message));
    } catch (e) {
      emit(SettingsImportError('Import fehlgeschlagen: $e'));
    }
  }

  /// Reset zu Initial State
  void resetState() {
    emit(const SettingsInitial());
  }
}

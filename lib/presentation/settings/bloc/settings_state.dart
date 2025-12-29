// Presentation Layer - Settings States
// State-Klassen für Export/Import-Operationen

import 'package:equatable/equatable.dart';

import '../../../domain/repositories/data_transfer_repository.dart';

/// Base State für Settings
abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

/// Initial State
class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

/// Export läuft
class SettingsExporting extends SettingsState {
  const SettingsExporting();
}

/// Export erfolgreich
class SettingsExportSuccess extends SettingsState {
  final String filename;

  const SettingsExportSuccess(this.filename);

  @override
  List<Object?> get props => [filename];
}

/// Export fehlgeschlagen
class SettingsExportError extends SettingsState {
  final String message;

  const SettingsExportError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Import läuft
class SettingsImporting extends SettingsState {
  const SettingsImporting();
}

/// Import erfolgreich
class SettingsImportSuccess extends SettingsState {
  final ImportResult result;

  const SettingsImportSuccess(this.result);

  @override
  List<Object?> get props => [result];
}

/// Import fehlgeschlagen
class SettingsImportError extends SettingsState {
  final String message;

  const SettingsImportError(this.message);

  @override
  List<Object?> get props => [message];
}

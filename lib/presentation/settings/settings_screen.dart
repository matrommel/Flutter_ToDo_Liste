import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../core/di/injection.dart';
import '../../core/services/biometric_auth_service.dart';
import '../../core/theme/theme_provider.dart';
import '../../domain/repositories/data_transfer_repository.dart';
import 'bloc/settings_cubit.dart';
import 'bloc/settings_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SettingsCubit>(),
      child: const _SettingsScreenContent(),
    );
  }
}

class _SettingsScreenContent extends StatelessWidget {
  const _SettingsScreenContent();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen'),
      ),
      body: BlocListener<SettingsCubit, SettingsState>(
        listener: (context, state) {
          if (state is SettingsExportSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✓ Backup gespeichert: ${state.filename}'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
            context.read<SettingsCubit>().resetState();
          } else if (state is SettingsExportError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
            context.read<SettingsCubit>().resetState();
          } else if (state is SettingsImportSuccess) {
            _showImportSuccessDialog(context, state.result);
          } else if (state is SettingsImportError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
            context.read<SettingsCubit>().resetState();
          }
        },
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            final isLoading =
                state is SettingsExporting || state is SettingsImporting;

            return ListView(
              children: [
                // Daten Section (NEU)
                _buildSectionHeader(context, '📦 Daten'),
                ListTile(
                  leading: const Icon(Icons.upload_file),
                  title: const Text('Daten exportieren'),
                  subtitle: const Text('Backup aller Kategorien und Items'),
                  trailing: isLoading && state is SettingsExporting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.chevron_right),
                  enabled: !isLoading,
                  onTap: () => _handleExport(context),
                ),
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('Daten importieren'),
                  subtitle: const Text('Backup wiederherstellen'),
                  trailing: isLoading && state is SettingsImporting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.chevron_right),
                  enabled: !isLoading,
                  onTap: () => _showImportOptionsDialog(context),
                ),
                const Divider(),

                // Design Section
                _buildSectionHeader(context, '🎨 Design'),
                ListTile(
                  leading: Icon(
                    themeProvider.isDarkMode
                        ? Icons.dark_mode
                        : Icons.light_mode,
                  ),
                  title: const Text('Theme'),
                  subtitle: Text(_getThemeModeText(themeProvider.themeMode)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showThemeDialog(context, themeProvider),
                ),
                const Divider(),

                // Info Section
                _buildSectionHeader(context, 'ℹ️ Info'),
                const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Version'),
                  subtitle: Text('1.0.0'),
                ),
                const ListTile(
                  leading: Icon(Icons.code),
                  title: Text('Entwickelt für'),
                  subtitle: Text('Agnes'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Hell';
      case ThemeMode.dark:
        return 'Dunkel';
      case ThemeMode.system:
        return 'System-Standard';
    }
  }

  void _showThemeDialog(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Theme auswählen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Hell'),
              subtitle: const Text('Immer helles Theme'),
              value: ThemeMode.light,
              groupValue: themeProvider.themeMode,
              onChanged: (mode) {
                if (mode != null) {
                  themeProvider.setThemeMode(mode);
                  Navigator.pop(dialogContext);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dunkel'),
              subtitle: const Text('Immer dunkles Theme'),
              value: ThemeMode.dark,
              groupValue: themeProvider.themeMode,
              onChanged: (mode) {
                if (mode != null) {
                  themeProvider.setThemeMode(mode);
                  Navigator.pop(dialogContext);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('System-Standard'),
              subtitle: const Text('Folgt den System-Einstellungen'),
              value: ThemeMode.system,
              groupValue: themeProvider.themeMode,
              onChanged: (mode) {
                if (mode != null) {
                  themeProvider.setThemeMode(mode);
                  Navigator.pop(dialogContext);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Export-Handler mit Biometric-Check
  Future<void> _handleExport(BuildContext context) async {
    final cubit = context.read<SettingsCubit>();

    // 1. Prüfe auf geschützte Kategorien
    final hasProtected = await cubit.hasProtectedCategories();

    // 2. Biometric-Authentifizierung falls nötig
    if (hasProtected) {
      final authenticated = await BiometricAuthService.authenticate(
        localizedReason: 'Authentifizieren Sie sich, um Daten zu exportieren',
      );

      if (!context.mounted) return;

      if (!authenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Export abgebrochen - Authentifizierung fehlgeschlagen'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
    }

    // 3. Export durchführen
    cubit.exportData();
  }

  // Import-Options-Dialog
  void _showImportOptionsDialog(BuildContext context) {
    bool deleteExisting = false;
    final cubit = context.read<SettingsCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (statefulContext, setState) => AlertDialog(
          title: const Text('Import-Optionen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Wählen Sie eine JSON-Backup-Datei zum Importieren.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                value: deleteExisting,
                onChanged: (value) =>
                    setState(() => deleteExisting = value ?? false),
                title: const Text('Alle vorhandenen Daten löschen'),
                subtitle: const Text(
                  'Vorsicht: Alle aktuellen Kategorien und Items werden gelöscht!',
                  style: TextStyle(fontSize: 12, color: Colors.red),
                ),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Abbrechen'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                if (deleteExisting) {
                  _showDeleteConfirmationDialog(context, deleteExisting);
                } else {
                  cubit.importData(deleteExistingData: deleteExisting);
                }
              },
              child: const Text('Datei auswählen'),
            ),
          ],
        ),
      ),
    );
  }

  // Warn-Dialog bei "Alle löschen"
  void _showDeleteConfirmationDialog(
      BuildContext context, bool deleteExisting) {
    final cubit = context.read<SettingsCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Warnung'),
          ],
        ),
        content: const Text(
          'Sind Sie sicher? Alle vorhandenen Kategorien und Items werden '
          'unwiderruflich gelöscht!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              cubit.importData(deleteExistingData: deleteExisting);
            },
            child: const Text('Löschen & importieren'),
          ),
        ],
      ),
    );
  }

  // Success-Dialog nach Import
  void _showImportSuccessDialog(BuildContext context, ImportResult result) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Import erfolgreich'),
          ],
        ),
        content: Text(
          'Importiert:\n'
          '• ${result.categoriesAdded} neue Kategorien\n'
          '• ${result.categoriesMerged} Kategorien zusammengeführt\n'
          '• ${result.itemsAdded} neue Items',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext); // Dialog schließen
              Navigator.pop(context); // Settings schließen (zurück zu Home)
              // Home wird automatisch neu geladen durch HomeCubit
            },
            child: const Text('OK'),
          ),
        ],
      ),
    ).then((_) {
      // Reset state after dialog closes
      if (context.mounted) {
        context.read<SettingsCubit>().resetState();
      }
    });
  }
}

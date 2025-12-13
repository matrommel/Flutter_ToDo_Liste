import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:matzo/core/theme/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen'),
      ),
      body: ListView(
        children: [
          // Design Section
          _buildSectionHeader(context, '🎨 Design'),
          ListTile(
            leading: Icon(
              themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
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
}

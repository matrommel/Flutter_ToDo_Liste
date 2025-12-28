import 'package:flutter/material.dart';
import '../../core/services/biometric_auth_service.dart';
import '../../domain/entities/category.dart';
import '../../domain/usecases/category/delete_category.dart';
import '../../domain/usecases/category/get_recursive_total_item_count.dart';
import '../../domain/usecases/category/update_category_protection.dart';
import '../../core/di/injection.dart';
import '../home/widgets/biometric_protection_dialog.dart';
import 'edit_category_dialog.dart';

class CategoryOptionsDialog {
  static void show(
    BuildContext context,
    Category category, {
    required VoidCallback onUpdate,
    bool isSubcategory = false,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 400,
            maxHeight: 400,
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Optionen für "${category.name}"',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                const Text('Wähle eine Aktion:'),
                const SizedBox(height: 24),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Schutz aktivieren/deaktivieren
                    FilledButton.icon(
                      onPressed: () async {
                        Navigator.of(dialogContext).pop();

                        // Wenn die Kategorie geschützt ist, erfordere Authentifizierung
                        if (category.isProtected) {
                          final authenticated =
                              await BiometricAuthService.authenticateForCategory(category.name);
                          if (!context.mounted) return;

                          if (!authenticated) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Authentifizierung erforderlich'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            return;
                          }
                        }

                        if (context.mounted) {
                          _showBiometricProtectionDialog(context, category, onUpdate);
                        }
                      },
                      icon: Icon(category.isProtected ? Icons.lock_open : Icons.lock),
                      label: Text(
                        category.isProtected ? 'Schutz deaktivieren' : 'Schutz aktivieren',
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Bearbeiten
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        if (context.mounted) {
                          EditCategoryDialog.show(context, category, onUpdate: onUpdate);
                        }
                      },
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Bearbeiten'),
                    ),
                    const SizedBox(height: 12),

                    // Löschen
                    FilledButton.icon(
                      onPressed: () async {
                        Navigator.of(dialogContext).pop();

                        // Wenn die Kategorie geschützt ist, erfordere Authentifizierung zum Löschen
                        if (category.isProtected) {
                          final authenticated =
                              await BiometricAuthService.authenticateForCategory(category.name);
                          if (!context.mounted) return;

                          if (!authenticated) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Authentifizierung erforderlich'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            return;
                          }
                        }

                        if (context.mounted) {
                          _showDeleteDialog(context, category, onUpdate, isSubcategory);
                        }
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Löschen'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Abbrechen
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('Abbrechen'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void _showBiometricProtectionDialog(
    BuildContext context,
    Category category,
    VoidCallback onUpdate,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => BiometricProtectionDialog(
        categoryName: category.name,
        isCurrentlyProtected: category.isProtected,
        onProtectionChanged: (isProtected) async {
          await getIt<UpdateCategoryProtection>()(category.id!, isProtected);
          onUpdate();
        },
      ),
    );
  }

  static void _showDeleteDialog(
    BuildContext context,
    Category category,
    VoidCallback onUpdate,
    bool isSubcategory,
  ) async {
    final totalCount = await getIt<GetRecursiveTotalItemCount>()(category.id!);
    final hasItems = totalCount > 0;

    final contentText = hasItems
        ? 'Möchtest du "${category.name}" wirklich löschen?\n\n'
            '⚠️ WARNUNG: Diese ${isSubcategory ? 'Unterkategorie' : 'Kategorie'} enthält $totalCount Item(s). '
            'Alle Items werden ebenfalls gelöscht!'
        : 'Möchtest du "${category.name}" wirklich löschen?';

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('${isSubcategory ? 'Unterkategorie' : 'Kategorie'} löschen?'),
        content: Text(contentText),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();

              await getIt<DeleteCategory>()(category.id!);

              if (context.mounted) {
                onUpdate();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✓ "${category.name}" wurde gelöscht'),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
  }
}

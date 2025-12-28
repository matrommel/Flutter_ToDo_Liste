import 'package:flutter/material.dart';
import '../../domain/entities/category.dart';
import '../../domain/usecases/category/update_category.dart';
import '../../core/di/injection.dart';

class EditCategoryDialog {
  static const List<IconData> _availableIcons = [
    Icons.list_alt,
    Icons.shopping_cart,
    Icons.work,
    Icons.home,
    Icons.fitness_center,
    Icons.flight_takeoff,
    Icons.school,
    Icons.favorite_outline,
    Icons.bookmark,
    Icons.restaurant,
    Icons.local_cafe,
    Icons.local_pizza,
    Icons.cake,
    Icons.breakfast_dining,
    Icons.local_bar,
    Icons.icecream,
    Icons.medical_services,
    Icons.healing,
    Icons.favorite,
    Icons.pool,
    Icons.directions_bike,
    Icons.directions_run,
    Icons.hiking,
    Icons.surfing,
    Icons.snowboarding,
    Icons.music_note,
    Icons.headphones,
    Icons.movie,
    Icons.videogame_asset,
    Icons.attractions,
    Icons.book,
    Icons.science,
    Icons.palette,
    Icons.photo_camera,
    Icons.videocam,
    Icons.beach_access,
    Icons.forest,
    Icons.pets,
    Icons.build,
    Icons.construction,
    Icons.electrical_services,
    Icons.store,
    Icons.storefront,
    Icons.attach_money,
    Icons.account_balance,
    Icons.savings,
    Icons.card_giftcard,
    Icons.redeem,
    Icons.celebration,
    Icons.party_mode,
    Icons.nightlife,
  ];

  static void show(
    BuildContext context,
    Category category, {
    required VoidCallback onUpdate,
  }) {
    final nameController = TextEditingController(text: category.name);
    final emojiController = TextEditingController();
    int? selectedIcon = category.iconCodePoint;
    bool useCustomEmoji = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 500,
              maxHeight: 600,
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kategorie bearbeiten',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: nameController,
                            autofocus: true,
                            decoration: const InputDecoration(
                              labelText: 'Name',
                              hintText: 'z.B. Einkaufen',
                            ),
                            textCapitalization: TextCapitalization.sentences,
                            onSubmitted: (value) async {
                              if (value.trim().isNotEmpty) {
                                Navigator.of(dialogContext).pop();

                                final emoji = emojiController.text.trim();
                                final iconCode = useCustomEmoji && emoji.isNotEmpty
                                    ? emoji.runes.first
                                    : selectedIcon;

                                await getIt<UpdateCategory>()(
                                  categoryId: category.id!,
                                  newName: value,
                                  newIconCodePoint: iconCode,
                                );

                                onUpdate();
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  useCustomEmoji ? 'Eigenes Emoji' : 'Icon auswählen',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () => setState(() {
                                  useCustomEmoji = !useCustomEmoji;
                                  if (useCustomEmoji) {
                                    selectedIcon = null;
                                  } else {
                                    selectedIcon = category.iconCodePoint ?? _availableIcons.first.codePoint;
                                    emojiController.clear();
                                  }
                                }),
                                icon: Icon(useCustomEmoji ? Icons.apps : Icons.emoji_emotions),
                                label: Text(useCustomEmoji ? 'Icons' : 'Emoji'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (useCustomEmoji)
                            TextField(
                              controller: emojiController,
                              decoration: const InputDecoration(
                                labelText: 'Emoji eingeben',
                                hintText: '🍕',
                                border: OutlineInputBorder(),
                              ),
                              maxLength: 2,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 32),
                            )
                          else
                            SizedBox(
                              height: 200,
                              child: GridView.builder(
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 6,
                                  childAspectRatio: 1,
                                  crossAxisSpacing: 4,
                                  mainAxisSpacing: 4,
                                ),
                                itemCount: _availableIcons.length,
                                itemBuilder: (context, index) {
                                  final icon = _availableIcons[index];
                                  final isSelected = icon.codePoint == selectedIcon;
                                  return GestureDetector(
                                    onTap: () => setState(() {
                                      selectedIcon = icon.codePoint;
                                    }),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: isSelected
                                              ? Theme.of(context).colorScheme.primary
                                              : Theme.of(context).colorScheme.outline,
                                          width: isSelected ? 2 : 1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        color: isSelected
                                            ? Theme.of(context).colorScheme.primaryContainer
                                            : null,
                                      ),
                                      child: Icon(
                                        icon,
                                        size: 24,
                                        color: isSelected
                                            ? Theme.of(context).colorScheme.primary
                                            : null,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: const Text('Abbrechen'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () async {
                          final name = nameController.text.trim();
                          if (name.isNotEmpty) {
                            Navigator.of(dialogContext).pop();

                            // Verwende Emoji wenn eingegeben, sonst Icon
                            final emoji = emojiController.text.trim();
                            final iconCode = useCustomEmoji && emoji.isNotEmpty
                                ? emoji.runes.first
                                : selectedIcon;

                            await getIt<UpdateCategory>()(
                              categoryId: category.id!,
                              newName: name,
                              newIconCodePoint: iconCode,
                            );

                            onUpdate();
                          }
                        },
                        child: const Text('Speichern'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

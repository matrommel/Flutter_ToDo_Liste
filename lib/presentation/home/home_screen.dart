// Presentation - Home Screen (Kategorien-Übersicht)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:confetti/confetti.dart';
import '../../core/di/injection.dart';
import '../../core/services/biometric_auth_service.dart';
import '../category/category_screen.dart';
import '../settings/settings_screen.dart';
import '../widgets/category_options_dialog.dart';
import 'bloc/home_cubit.dart';
import 'bloc/home_state.dart';
import 'widgets/category_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HomeCubit>()..loadCategories(),
      child: const _HomeScreenContent(),
    );
  }
}

class _HomeScreenContent extends StatefulWidget {
  const _HomeScreenContent();

  @override
  State<_HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<_HomeScreenContent> {
  late ConfettiController _confettiController;

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

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  /// Easter Egg: Spezielle Namen haben Konfetti
  bool _isEasterEggCategory(String name) {
    final specialNames = ['agnes', 'tamina', 'matze'];
    return specialNames.contains(name.toLowerCase());
  }

  void _triggerConfetti() {
    if (mounted) {
      _confettiController.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Setze Context für BiometricAuthService
    BiometricAuthService.setContext(context);
    
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Meine Listen'),
            actions: [
              // Menü mit Sortierungsoptionen (konsistent mit CategoryScreen)
              BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  final sortAscending = state is HomeLoaded ? state.sortAscending : true;

                  return PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    tooltip: 'Mehr Aktionen',
                    onSelected: (value) async {
                      if (value == 'toggle_sort') {
                        await context.read<HomeCubit>().toggleSortOrder();
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'toggle_sort',
                        child: Row(
                          children: [
                            Icon(sortAscending ? Icons.arrow_downward : Icons.arrow_upward),
                            const SizedBox(width: 12),
                            Text('Sortierung ${sortAscending ? 'absteigend' : 'aufsteigend'}'),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showAddCategoryDialog(context),
                tooltip: 'Neue Kategorie',
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
                tooltip: 'Einstellungen',
              ),
            ],
          ),
          body: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              if (state is HomeLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is HomeError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Fehler: ${state.message}',
                        textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<HomeCubit>().loadCategories(),
                    child: const Text('Erneut versuchen'),
                  ),
                ],
              ),
            );
          }

          if (state is HomeLoaded) {
            if (state.categories.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Noch keine Listen vorhanden',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tippe auf + um eine neue Liste zu erstellen',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: state.categories.length,
              itemBuilder: (context, index) {
                final category = state.categories[index];
                final openCount = state.itemCounts[category.id] ?? 0;
                final totalCount = state.totalItemCounts[category.id] ?? 0;
                final subcats = state.subcategories[category.id] ?? [];

                return CategoryCard(
                  category: category,
                  openItemsCount: openCount,
                  totalItemsCount: totalCount,
                  subcategories: subcats,
                  subcategoryOpenCounts: state.subcategoryOpenCounts,
                  subcategoryTotalCounts: state.subcategoryTotalCounts,
                  onTap: () => _navigateToCategory(context, category),
                  onLongPress: () => CategoryOptionsDialog.show(
                    context,
                    category,
                    onUpdate: () => context.read<HomeCubit>().loadCategories(),
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
        ),
        IgnorePointer(
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            particleDrag: 0.05,
            emissionFrequency: 0.05,
            numberOfParticles: 100,
            gravity: 0.05,
            shouldLoop: false,
            colors: const [
              Colors.red,
              Colors.blue,
              Colors.green,
              Colors.yellow,
              Colors.purple,
              Colors.pink,
              Colors.orange,
              Colors.cyan,
            ],
          ),
        ),
      ],
    );
  }

  void _navigateToCategory(BuildContext context, category) async {
    print('DEBUG: _navigateToCategory called for ${category.name}');
    print('DEBUG: isProtected = ${category.isProtected}');
    
    // Wenn Kategorie geschützt ist, Authentifizierung durchführen
    if (category.isProtected) {
      print('DEBUG: Category is protected, attempting biometric auth...');
      final authenticated = await BiometricAuthService.authenticateForCategory(category.name);
      print('DEBUG: Authentication result: $authenticated');
      
      if (!authenticated) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Authentifizierung fehlgeschlagen für "${category.name}"'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        return;
      }
    }

    if (context.mounted) {
      print('DEBUG: Navigation to category ${category.name}');
      final cubit = context.read<HomeCubit>();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CategoryScreen(
            categoryId: category.id!,
            categoryName: category.name,
          ),
        ),
      ).then((_) {
        // Nach Rückkehr neu laden, falls Items geändert wurden
        cubit.loadCategories();
      });
    }
  }

  void _showAddCategoryDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emojiController = TextEditingController();
    int? selectedIcon = _availableIcons.first.codePoint;
    bool useCustomEmoji = false;
    final cubit = context.read<HomeCubit>();

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
                    'Neue Kategorie',
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
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      Navigator.of(dialogContext).pop();
                      cubit.addNewCategory(
                        value,
                        iconCodePoint: useCustomEmoji ? null : selectedIcon,
                      );
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
                          selectedIcon = _availableIcons.first.codePoint;
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
                        onPressed: () {
                          final name = nameController.text.trim();
                          if (name.isNotEmpty) {
                            Navigator.of(dialogContext).pop();

                            // Verwende Emoji wenn eingegeben, sonst Icon
                            final emoji = emojiController.text.trim();
                            final iconCode = useCustomEmoji && emoji.isNotEmpty
                                ? emoji.runes.first
                                : selectedIcon;

                            cubit.addNewCategory(
                              name,
                              iconCodePoint: iconCode,
                            );
                            // Konfetti triggern wenn spezielle Namen
                            if (_isEasterEggCategory(name)) {
                              Future.delayed(const Duration(milliseconds: 500), () {
                                _triggerConfetti();
                              });
                            }
                          }
                        },
                        child: const Text('Erstellen'),
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

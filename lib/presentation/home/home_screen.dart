// Presentation - Home Screen (Kategorien-Übersicht)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/di/injection.dart';
import '../category/category_screen.dart';
import '../settings/settings_screen.dart';
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

class _HomeScreenContent extends StatelessWidget {
  const _HomeScreenContent();

  static const List<IconData> _availableIcons = [
    Icons.list_alt,
    Icons.shopping_cart,
    Icons.work,
    Icons.home,
    Icons.fitness_center,
    Icons.flight_takeoff,
    Icons.school,
    Icons.favorite_outline,
    Icons.calendar_today,
    Icons.bookmark,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meine Listen'),
        actions: [
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

                return CategoryCard(
                  category: category,
                  openItemsCount: openCount,
                  totalItemsCount: totalCount,
                  onTap: () => _navigateToCategory(context, category),
                  onLongPress: () =>
                      _showDeleteDialog(context, category.id!, category.name),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _navigateToCategory(BuildContext context, category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryScreen(
          categoryId: category.id!,
          categoryName: category.name,
        ),
      ),
    ).then((_) {
      // Nach Rückkehr neu laden, falls Items geändert wurden
      context.read<HomeCubit>().loadCategories();
    });
  }

  void _showAddCategoryDialog(BuildContext context) {
    final controller = TextEditingController();
    int selectedIcon = _availableIcons.first.codePoint;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Neue Kategorie'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'z.B. Einkaufen',
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      Navigator.of(dialogContext).pop();
                      context.read<HomeCubit>().addNewCategory(
                            value,
                            iconCodePoint: selectedIcon,
                          );
                    }
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Icon auswählen',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableIcons.map((icon) {
                    final isSelected = icon.codePoint == selectedIcon;
                    return ChoiceChip(
                      label: Icon(icon),
                      selected: isSelected,
                      onSelected: (_) => setState(() {
                        selectedIcon = icon.codePoint;
                      }),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Abbrechen'),
            ),
            FilledButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  Navigator.of(dialogContext).pop();
                  context.read<HomeCubit>().addNewCategory(
                        name,
                        iconCodePoint: selectedIcon,
                      );
                }
              },
              child: const Text('Erstellen'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, int categoryId, String name) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Kategorie löschen?'),
        content: Text(
          'Möchtest du "$name" und alle darin enthaltenen Items wirklich löschen?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<HomeCubit>().removeCategory(categoryId);
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

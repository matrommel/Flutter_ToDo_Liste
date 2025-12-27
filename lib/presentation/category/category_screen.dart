// Presentation - Category Screen (Todo-Items einer Kategorie)
// USABILITY IMPROVEMENTS:
// - Edit-Dialog für Items
// - SnackBar-Feedback mit UNDO
// - Bulk-Aktionen (Alle abhaken, Erledigte löschen)
// - Verbesserte Benutzerführung

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/di/injection.dart';
import '../../domain/usecases/category/add_category.dart';
import '../../domain/usecases/category/get_recursive_item_count.dart';
import '../../domain/usecases/category/get_recursive_total_item_count.dart';
import 'bloc/category_cubit.dart';
import 'bloc/category_state.dart';
import 'widgets/add_item_dialog.dart';
import 'widgets/edit_item_dialog.dart';
import 'widgets/subcategory_tile.dart';
import 'widgets/todo_item_tile.dart';

class CategoryScreen extends StatelessWidget {
  final int categoryId;
  final String categoryName;
  final List<Map<String, dynamic>> breadcrumbs;

  const CategoryScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
    this.breadcrumbs = const [],
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CategoryCubit>()..loadItems(categoryId),
      child: _CategoryScreenContent(
        categoryId: categoryId,
        categoryName: categoryName,
        breadcrumbs: breadcrumbs,
      ),
    );
  }
}

class _CategoryScreenContent extends StatelessWidget {
  final int categoryId;
  final String categoryName;
  final List<Map<String, dynamic>> breadcrumbs;

  const _CategoryScreenContent({
    required this.categoryId,
    required this.categoryName,
    this.breadcrumbs = const [],
  });

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

  /// Easter Egg: Spezielle Namen haben Konfetti
  bool _isEasterEggCategory() {
    final specialNames = ['agnes', 'tamina', 'matze'];
    return specialNames.contains(categoryName.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: breadcrumbs.isEmpty
              ? Text(categoryName)
              : _buildBreadcrumbs(context),
          actions: [
            // Bulk-Actions Menu
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              tooltip: 'Mehr Aktionen',
              onSelected: (value) {
                switch (value) {
                  case 'toggle_sort':
                    context.read<CategoryCubit>().toggleSortOrder();
                    break;
                  case 'toggle_completed':
                    context.read<CategoryCubit>().toggleShowCompleted();
                    break;
                  case 'toggle_subcategories':
                    context.read<CategoryCubit>().toggleShowSubcategories();
                    break;
                  case 'mark_all_done':
                    _showMarkAllDoneDialog(context);
                    break;
                  case 'delete_completed':
                    _showDeleteCompletedDialog(context);
                    break;
                }
              },
              itemBuilder: (context) {
                final state = context.read<CategoryCubit>().state;
                final showCompleted = state is CategoryLoaded ? state.showCompleted : true;
                final showSubcategories = state is CategoryLoaded ? state.showSubcategories : true;
                final sortAscending = state is CategoryLoaded ? state.sortAscending : true;

                return [
                  PopupMenuItem(
                    value: 'toggle_sort',
                    child: Row(
                      children: [
                        Icon(sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
                        const SizedBox(width: 12),
                        Text('Sortierung ${sortAscending ? 'absteigend' : 'aufsteigend'}'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'toggle_completed',
                    child: Row(
                      children: [
                        Icon(showCompleted ? Icons.visibility_off : Icons.visibility),
                        const SizedBox(width: 12),
                        Text(showCompleted ? 'Abgehakte Items ausblenden' : 'Abgehakte Items einblenden'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'toggle_subcategories',
                    child: Row(
                      children: [
                        Icon(showSubcategories ? Icons.folder_off : Icons.folder),
                        const SizedBox(width: 12),
                        Text(showSubcategories ? 'Unterkategorien ausblenden' : 'Unterkategorien einblenden'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'mark_all_done',
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline),
                        SizedBox(width: 12),
                        Text('Alle als erledigt markieren'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete_completed',
                    child: Row(
                      children: [
                        Icon(Icons.delete_sweep_outlined),
                        SizedBox(width: 12),
                        Text('Erledigte löschen'),
                      ],
                    ),
                  ),
                ];
              },
            ),
            IconButton(
              icon: const Icon(Icons.create_new_folder),
              onPressed: () => _showAddSubcategoryDialog(context),
              tooltip: 'Unterkategorie hinzufügen',
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddItemDialog(context),
              tooltip: 'Neues Item',
            ),
          ],
        ),
        body: BlocConsumer<CategoryCubit, CategoryState>(
          listener: (context, state) {
          if (state is CategoryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
                action: SnackBarAction(
                  label: 'OK',
                  textColor: Colors.white,
                  onPressed: () {},
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CategoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CategoryLoaded) {
            final openItems = state.openItems;
            final completedItems = state.completedItems;
            final subcategories = state.subcategories;

            if (openItems.isEmpty && completedItems.isEmpty && subcategories.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.checklist_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Noch keine Items vorhanden',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tippe auf + um ein neues Item hinzuzufügen',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return ListView(
              children: [
                // Unterkategorien
                if (state.showSubcategories && subcategories.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.folder_outlined,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Unterkategorien (${subcategories.length})',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                  ...subcategories.map((subcat) {
                    return FutureBuilder<List<int>>(
                      future: Future.wait([
                        getIt<GetRecursiveItemCount>()(subcat.id!),
                        getIt<GetRecursiveTotalItemCount>()(subcat.id!),
                      ]),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return SubcategoryTile(
                            category: subcat,
                            openItemsCount: 0,
                            totalItemsCount: 0,
                            onTap: () => _navigateToSubcategory(context, subcat),
                          );
                        }
                        final openCount = snapshot.data![0];
                        final totalCount = snapshot.data![1];
                        return SubcategoryTile(
                          category: subcat,
                          openItemsCount: openCount,
                          totalItemsCount: totalCount,
                          onTap: () => _navigateToSubcategory(context, subcat),
                        );
                      },
                    );
                  }),
                  const SizedBox(height: 8),
                ],

                // Offene Items mit Reorder
                if (openItems.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: [
                        Text(
                          'Offen (${openItems.length})',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                  ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: openItems.length,
                    onReorder: (oldIndex, newIndex) => _handleReorder(context, oldIndex, newIndex),
                    itemBuilder: (context, index) {
                      final item = openItems[index];
                      return TodoItemTile(
                        key: ValueKey('open_${item.id}'),
                        item: item,
                        onToggle: () => _handleToggle(context, item),
                        onIncrement: () => _handleIncrement(context, item),
                        onDecrement: () => _handleDecrement(context, item),
                        onDelete: () => _handleDelete(context, item),
                        onEdit: () => _showEditDialog(context, item),
                      );
                    },
                  ),
                ],

                // Erledigte Items (optional)
                if (state.showCompleted && completedItems.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'Erledigt (${completedItems.length})',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  ...completedItems.map((item) => TodoItemTile(
                        item: item,
                        onToggle: () => _handleToggle(context, item),
                        onIncrement: () => _handleIncrement(context, item),
                        onDecrement: () => _handleDecrement(context, item),
                        onDelete: () => _handleDelete(context, item),
                        onEdit: () => _showEditDialog(context, item),
                      )),
                  const SizedBox(height: 16),
                ],
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(context),
        tooltip: 'Neues Item hinzufügen',
        child: const Icon(Icons.add),
      ),
    );
  }

  // Handler-Methoden mit SnackBar-Feedback

  void _handleReorder(BuildContext context, int oldIndex, int newIndex) {
    context.read<CategoryCubit>().reorderOpenItems(oldIndex, newIndex);
  }

  void _handleToggle(BuildContext context, item) {
    final cubit = context.read<CategoryCubit>();
    cubit.toggleItem(item.id!);
  }

  void _handleIncrement(BuildContext context, item) {
    context.read<CategoryCubit>().incrementCount(item.id!, item.count);
  }

  void _handleDecrement(BuildContext context, item) {
    if (item.count <= 1) return;
    context.read<CategoryCubit>().decrementCount(item.id!, item.count);
  }

  void _handleDelete(BuildContext context, item) {
    final cubit = context.read<CategoryCubit>();
    cubit.removeItem(item.id!);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.title} wurde gelöscht'),
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Rückgängig',
          onPressed: () => cubit.restoreLastDeletedItem(),
        ),
      ),
    );
  }

  // Dialoge

  void _showAddItemDialog(BuildContext context) async {
    final state = context.read<CategoryCubit>().state;
    final suggestions = state is CategoryLoaded
        ? state.completedItems.map((e) => e.title).toSet().toList()
        : <String>[];

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => AddItemDialog(suggestions: suggestions),
    );

    if (result != null && context.mounted) {
      context.read<CategoryCubit>().addNewItem(
            result['title'] as String,
            count: result['count'] as int,
            description: result['description'] as String?,
          );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ ${result['title']} hinzugefügt'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showAddSubcategoryDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emojiController = TextEditingController();
    int? selectedIcon = _availableIcons.first.codePoint;
    bool useCustomEmoji = false;
    final cubit = context.read<CategoryCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (builderContext, setState) => Dialog(
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
                    'Unterkategorie hinzufügen',
                    style: Theme.of(builderContext).textTheme.headlineSmall,
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
                    hintText: 'z.B. Salami',
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      Navigator.of(dialogContext).pop();
                      final emoji = emojiController.text.trim();
                      final iconCode = useCustomEmoji && emoji.isNotEmpty
                          ? emoji.runes.first
                          : selectedIcon ?? _availableIcons.first.codePoint;
                      _addSubcategory(context, cubit, value, iconCode);
                    }
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        useCustomEmoji ? 'Eigenes Emoji' : 'Icon auswählen',
                        style: Theme.of(builderContext).textTheme.titleSmall,
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
                                    ? Theme.of(builderContext).colorScheme.primary
                                    : Theme.of(builderContext).colorScheme.outline,
                                width: isSelected ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              color: isSelected
                                  ? Theme.of(builderContext).colorScheme.primaryContainer
                                  : null,
                            ),
                            child: Icon(
                              icon,
                              size: 24,
                              color: isSelected
                                  ? Theme.of(builderContext).colorScheme.primary
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
                                : selectedIcon ?? _availableIcons.first.codePoint;

                            _addSubcategory(context, cubit, name, iconCode);
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

  void _addSubcategory(BuildContext context, CategoryCubit cubit, String name, int iconCodePoint) async {
    final addCategory = getIt<AddCategory>();
    try {
      await addCategory(
        name,
        iconCodePoint: iconCodePoint,
        parentCategoryId: categoryId,
      );

      if (context.mounted) {
        // Reload category to show new subcategory
        cubit.loadItems(categoryId);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Unterkategorie "$name" erstellt'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showEditDialog(BuildContext context, item) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => EditItemDialog(
        initialTitle: item.title,
        initialCount: item.count,
        initialDescription: item.description,
        initialLinks: item.links,
      ),
    );

    if (result != null && context.mounted) {
      context.read<CategoryCubit>().editItem(
            item.id!,
            result['title'] as String,
            result['count'] as int,
            description: result['description'] as String?,
            links: result['links'] as List<String>?,
          );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Item aktualisiert'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showMarkAllDoneDialog(BuildContext context) {
    final state = context.read<CategoryCubit>().state;
    if (state is! CategoryLoaded || state.openItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Keine offenen Items vorhanden'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Alle als erledigt markieren?'),
        content: Text(
          'Möchtest du wirklich alle ${state.openItems.length} offenen Items abhaken?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Abbrechen'),
          ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<CategoryCubit>().markAllAsComplete();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✓ ${state.openItems.length} Items abgehakt'),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Alle abhaken'),
            ),
        ],
      ),
    );
  }

  void _showDeleteCompletedDialog(BuildContext context) {
    final state = context.read<CategoryCubit>().state;
    if (state is! CategoryLoaded || state.completedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Keine erledigten Items vorhanden'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Erledigte Items löschen?'),
        content: Text(
          'Möchtest du wirklich alle ${state.completedItems.length} erledigten Items löschen?\n\n'
          'Diese Aktion kann nicht rückgängig gemacht werden.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              final count = state.completedItems.length;
              context.read<CategoryCubit>().deleteAllCompleted();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✓ $count erledigte Items gelöscht'),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
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

  Widget _buildBreadcrumbs(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...breadcrumbs.asMap().entries.map((entry) {
                  final index = entry.key;
                  final crumb = entry.value;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () {
                          // Pop back to this level
                          final popCount = breadcrumbs.length - index;
                          for (int i = 0; i < popCount; i++) {
                            Navigator.of(context).pop();
                          }
                        },
                        child: Text(
                          crumb['name'] as String,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      ),
                      const SizedBox(width: 4),
                    ],
                  );
                }),
                Text(
                  categoryName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _navigateToSubcategory(BuildContext context, category) async {
    final newBreadcrumbs = [
      ...breadcrumbs,
      {'id': categoryId, 'name': categoryName},
    ];

    final cubit = context.read<CategoryCubit>();

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryScreen(
          categoryId: category.id!,
          categoryName: category.name,
          breadcrumbs: newBreadcrumbs,
        ),
      ),
    );

    // Reload category after returning from subcategory to refresh progress
    if (context.mounted) {
      cubit.loadItems(categoryId);
    }
  }
}

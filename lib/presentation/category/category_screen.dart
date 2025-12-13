// Presentation - Category Screen (Todo-Items einer Kategorie)
// USABILITY IMPROVEMENTS:
// - Edit-Dialog für Items
// - SnackBar-Feedback mit UNDO
// - Bulk-Aktionen (Alle abhaken, Erledigte löschen)
// - Verbesserte Benutzerführung

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/di/injection.dart';
import '../home/widgets/confetti_overlay.dart';
import 'bloc/category_cubit.dart';
import 'bloc/category_state.dart';
import 'widgets/add_item_dialog.dart';
import 'widgets/edit_item_dialog.dart';
import 'widgets/todo_item_tile.dart';

class CategoryScreen extends StatelessWidget {
  final int categoryId;
  final String categoryName;

  const CategoryScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CategoryCubit>()..loadItems(categoryId),
      child: _CategoryScreenContent(categoryName: categoryName),
    );
  }
}

class _CategoryScreenContent extends StatelessWidget {
  final String categoryName;

  const _CategoryScreenContent({required this.categoryName});

  /// Easter Egg: Spezielle Namen haben Konfetti
  bool _isEasterEggCategory() {
    final specialNames = ['agnes', 'tamina', 'matze'];
    return specialNames.contains(categoryName.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    return ConfettiOverlay(
      triggerConfetti: _isEasterEggCategory(),
      child: Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
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

            if (openItems.isEmpty && completedItems.isEmpty) {
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

  void _showEditDialog(BuildContext context, item) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => EditItemDialog(
        initialTitle: item.title,
        initialCount: item.count,
      ),
    );

    if (result != null && context.mounted) {
      context.read<CategoryCubit>().editItem(
            item.id!,
            result['title'] as String,
            result['count'] as int,
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
      ),
    );
  }
}

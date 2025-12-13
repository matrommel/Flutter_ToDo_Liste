// Presentation - Verbessertes Todo Item Tile Widget
// USABILITY IMPROVEMENTS:
// - Größere Touch Targets (48x48px minimum)
// - Bestätigung bei Swipe-to-Delete
// - Besseres visuelles Feedback
// - Tap auf Titel öffnet Edit-Dialog

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:matzo/domain/entities/todo_item.dart';

class TodoItemTile extends StatelessWidget {
  final TodoItem item;
  final VoidCallback onToggle;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onDelete;
  final VoidCallback? onEdit; // NEU: Edit-Funktion

  const TodoItemTile({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onIncrement,
    required this.onDecrement,
    required this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (context) => _showDeleteConfirmation(context),
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Colors.white,
            icon: Icons.delete_outline,
            label: 'Löschen',
          ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: InkWell(
          onTap: onEdit, // Tap auf ganzes Item öffnet Edit-Dialog
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                // Checkbox mit größerem Touch Target
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Transform.scale(
                      scale: 1.2, // Größere Checkbox
                      child: Checkbox(
                        value: item.isCompleted,
                        onChanged: (_) => onToggle(),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 4),
                
                // Titel
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 16,
                          decoration: item.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: item.isCompleted
                              ? Theme.of(context).colorScheme.onSurfaceVariant
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      if (onEdit != null)
                        Text(
                          'Tippen zum Bearbeiten',
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Counter (nur bei nicht erledigten Items)
                if (!item.isCompleted)
                  _buildCounter(context)
                else
                  _buildCompletedBadge(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCounter(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Minus Button - VERGRÖSSERT
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, size: 24),
            onPressed: item.count > 1 ? onDecrement : null,
            padding: const EdgeInsets.all(12), // Mindestens 48x48px
            constraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 48,
            ),
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            tooltip: 'Anzahl verringern',
          ),
          
          // Count Display
          Container(
            constraints: const BoxConstraints(minWidth: 32),
            child: Text(
              '${item.count}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
            ),
          ),
          
          // Plus Button - VERGRÖSSERT
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 24),
            onPressed: onIncrement,
            padding: const EdgeInsets.all(12), // Mindestens 48x48px
            constraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 48,
            ),
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            tooltip: 'Anzahl erhöhen',
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedBadge(BuildContext context) {
    return Chip(
      label: Text(
        '${item.count}',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Item löschen?'),
        content: Text(
          'Möchtest du "${item.title}" wirklich löschen?\n\n'
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
              onDelete();
              
              // Optional: Undo via SnackBar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${item.title} wurde gelöscht'),
                  duration: const Duration(seconds: 3),
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
}

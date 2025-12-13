// Presentation - Category Card Widget mit Fortschrittsbalken

import 'package:flutter/material.dart';
import 'package:matzo/domain/entities/category.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  final int openItemsCount;
  final int totalItemsCount;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const CategoryCard({
    super.key,
    required this.category,
    required this.openItemsCount,
    required this.totalItemsCount,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final completedCount = totalItemsCount - openItemsCount;
    final progress = totalItemsCount > 0 ? completedCount / totalItemsCount : 0.0;
    
    return Card(
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon und Name
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getIconForCategory(category),
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      category.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              
              // Fortschritt Text
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    totalItemsCount == 0
                        ? 'Keine Items'
                        : '$completedCount/$totalItemsCount',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  if (totalItemsCount > 0)
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _getProgressColor(context, progress),
                          ),
                    ),
                ],
              ),
              
              // Fortschrittsbalken
              if (totalItemsCount > 0) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getProgressColor(context, progress),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getProgressColor(BuildContext context, double progress) {
    if (progress >= 1.0) {
      return Colors.green;
    } else if (progress >= 0.5) {
      return Theme.of(context).colorScheme.primary;
    } else {
      return Colors.orange;
    }
  }

  IconData _getIconForCategory(Category category) {
    if (category.iconCodePoint != null) {
      return IconData(category.iconCodePoint!, fontFamily: 'MaterialIcons');
    }

    final lowerName = category.name.toLowerCase();
    if (lowerName.contains('einkauf')) return Icons.shopping_cart;
    if (lowerName.contains('arbeit')) return Icons.work;
    if (lowerName.contains('haushalt')) return Icons.home;
    if (lowerName.contains('sport')) return Icons.fitness_center;
    if (lowerName.contains('reise')) return Icons.flight;
    if (lowerName.contains('projekt')) return Icons.folder;
    if (lowerName.contains('buch') || lowerName.contains('lesen')) return Icons.book;

    return Icons.list_alt;
  }
}

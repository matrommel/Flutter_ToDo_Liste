// Presentation - Subcategory Tile Widget mit Fortschrittsbalken

import 'package:flutter/material.dart';
import 'package:matzo/domain/entities/category.dart';

class SubcategoryTile extends StatelessWidget {
  final Category category;
  final int openItemsCount;
  final int totalItemsCount;
  final VoidCallback onTap;

  const SubcategoryTile({
    super.key,
    required this.category,
    required this.openItemsCount,
    required this.totalItemsCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final completedCount = totalItemsCount - openItemsCount;
    final progress = totalItemsCount > 0 ? completedCount / totalItemsCount : 0.0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getIconForCategory(category),
            color: Theme.of(context).colorScheme.onSecondaryContainer,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                category.name,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (category.isProtected)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.lock,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
          ],
        ),
        subtitle: totalItemsCount > 0
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$completedCount/$totalItemsCount',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _getProgressColor(context, progress),
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 4,
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getProgressColor(context, progress),
                      ),
                    ),
                  ),
                ],
              )
            : Text(
                'Keine Items',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
        trailing: Icon(
          Icons.chevron_right,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
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

    return Icons.folder_outlined;
  }
}

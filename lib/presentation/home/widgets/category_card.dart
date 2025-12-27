// Presentation - Category Card Widget mit Fortschrittsbalken

import 'package:flutter/material.dart';
import 'package:matzo/domain/entities/category.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  final int openItemsCount;
  final int totalItemsCount;
  final List<Category> subcategories;
  final Map<int, int> subcategoryOpenCounts;
  final Map<int, int> subcategoryTotalCounts;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const CategoryCard({
    super.key,
    required this.category,
    required this.openItemsCount,
    required this.totalItemsCount,
    this.subcategories = const [],
    this.subcategoryOpenCounts = const {},
    this.subcategoryTotalCounts = const {},
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
                    child: _buildCategoryIcon(
                      context,
                      category,
                      size: 20,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
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
                  // Schloss-Icon für geschützte Kategorien
                  if (category.isProtected)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Icon(
                        Icons.lock,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                ],
              ),

              // Subcategory-Quadrate
              if (subcategories.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildSubcategorySquares(context),
              ],

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
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
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

  Widget _buildSubcategorySquares(BuildContext context) {
    const maxVisible = 3;
    final visibleSubcats = subcategories.take(maxVisible).toList();
    final remainingCount = subcategories.length - maxVisible;

    return SizedBox(
      height: 32,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ...visibleSubcats.map((subcat) {
              final openCount = subcategoryOpenCounts[subcat.id] ?? 0;
              final totalCount = subcategoryTotalCounts[subcat.id] ?? 0;
              final completedCount = totalCount - openCount;
              final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Hintergrund-Kreis
                      CircularProgressIndicator(
                        value: 1.0,
                        strokeWidth: 3,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                        ),
                      ),
                      // Fortschritts-Kreis
                      CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 3,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getProgressColor(context, progress),
                        ),
                      ),
                      // Icon in der Mitte
                      _buildCategoryIcon(
                        context,
                        subcat,
                        size: 14,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ],
                  ),
                ),
              );
            }),
            if (remainingCount > 0)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    '+$remainingCount',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(
    BuildContext context,
    Category category, {
    required double size,
    Color? color,
  }) {
    if (category.iconCodePoint != null) {
      final codePoint = category.iconCodePoint!;

      // Emojis haben typischerweise höhere Unicode-Werte (> 0x1F000)
      // Material Icons liegen im Private Use Area (0xE000-0xF8FF)
      final isEmoji = codePoint > 0x1F000 || (codePoint > 0x10000 && codePoint < 0x1F000);

      if (isEmoji) {
        return Text(
          String.fromCharCode(codePoint),
          style: TextStyle(
            fontSize: size * 0.8,
            height: 1.0, // Verhindert zusätzlichen vertikalen Spacing
          ),
        );
      } else {
        return Icon(
          IconData(codePoint, fontFamily: 'MaterialIcons'),
          size: size,
          color: color,
        );
      }
    }

    // Fallback: Name-basierte Icon-Erkennung
    final lowerName = category.name.toLowerCase();
    IconData iconData = Icons.list_alt;

    if (lowerName.contains('einkauf')) iconData = Icons.shopping_cart;
    else if (lowerName.contains('arbeit')) iconData = Icons.work;
    else if (lowerName.contains('haushalt')) iconData = Icons.home;
    else if (lowerName.contains('sport')) iconData = Icons.fitness_center;
    else if (lowerName.contains('reise')) iconData = Icons.flight;
    else if (lowerName.contains('projekt')) iconData = Icons.folder;
    else if (lowerName.contains('buch') || lowerName.contains('lesen')) iconData = Icons.book;

    return Icon(iconData, size: size, color: color);
  }
}

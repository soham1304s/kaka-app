import 'package:flutter/material.dart';

class CategoryBar extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onSelectCategory;

  const CategoryBar({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onSelectCategory,
  });

  String _getCategoryIcon(String category) {
    switch (category) {
      case 'Burgers':
        return '🍔';
      case 'Pizza':
        return '🍕';
      case 'Asian & Bowls':
        return '🍜';
      case 'Healthy & Salads':
        return '🥗';
      case 'Desserts':
        return '🍰';
      case 'Beverages':
        return '🥤';
      case 'All':
      default:
        return '🍽️';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat == selectedCategory;
          final icon = _getCategoryIcon(cat);

          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => onSelectCategory(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : (isDark ? const Color(0xFF222730) : Colors.white),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : (isDark ? const Color(0xFF2E3440) : const Color(0xFFE5E7EB)),
                    width: 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: theme.colorScheme.primary.withAlpha(70),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      icon,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      cat,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white70 : const Color(0xFF374151)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

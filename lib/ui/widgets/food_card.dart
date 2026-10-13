import 'package:flutter/material.dart';
import '../../domain/models/food_item.dart';
import 'app_network_image.dart';

class FoodCard extends StatelessWidget {
  final FoodItem food;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onAddToCart;

  const FoodCard({
    super.key,
    required this.food,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteToggle,
    required this.onAddToCart,
  });

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Burgers':
        return Icons.lunch_dining_rounded;
      case 'Pizza':
        return Icons.local_pizza_rounded;
      case 'Asian & Bowls':
        return Icons.ramen_dining_rounded;
      case 'Healthy & Salads':
        return Icons.eco_rounded;
      case 'Desserts':
        return Icons.cake_rounded;
      case 'Beverages':
        return Icons.local_cafe_rounded;
      default:
        return Icons.fastfood_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E222A) : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark ? const Color(0xFF2C323E) : const Color(0xFFEFF0F3),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withAlpha(50) : const Color(0x0A000000),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image container with overlays
              SizedBox(
                height: 115,
                width: double.infinity,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(21)),
                        child: AppNetworkImage(
                          imageUrl: food.imageUrl,
                          placeholderText: food.name,
                          placeholderIcon: _getCategoryIcon(food.category),
                        ),
                      ),
                    ),
                    // Badge (Chef Special / Popular / Veg)
                    if (food.isChefSpecial || food.isPopular)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: food.isChefSpecial
                                ? const Color(0xFFFF9800)
                                : theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(40),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Text(
                            food.isChefSpecial ? '★ CHEF' : '🔥 POPULAR',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    // Favorite Heart Button
                    Positioned(
                      top: 7,
                      right: 7,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onFavoriteToggle,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E222A).withAlpha(220)
                                  : Colors.white.withAlpha(230),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(30),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Icon(
                              isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              size: 17,
                              color: isFavorite
                                  ? theme.colorScheme.primary
                                  : (isDark ? Colors.white70 : Colors.black54),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Delivery time floating tag
                    Positioned(
                      bottom: 7,
                      right: 7,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(190),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.timer_outlined, size: 11, color: Colors.white),
                            const SizedBox(width: 3),
                            Text(
                              food.deliveryTime,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Category & Rating
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              food.category.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFB300)),
                          const SizedBox(width: 2),
                          Text(
                            food.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      // Title
                      Text(
                        food.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          height: 1.15,
                        ),
                      ),
                      // Short description / calories
                      Text(
                        '${food.calories} kcal • ${food.isVegetarian ? 'Veg' : 'Gourmet'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5,
                          color: isDark ? Colors.white54 : const Color(0xFF6B7280),
                        ),
                      ),
                      // Price and Add button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: RichText(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '₹',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  TextSpan(
                                    text: food.price.toStringAsFixed(2),
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? Colors.white : const Color(0xFF111827),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: onAddToCart,
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.colorScheme.primary.withAlpha(60),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.add_rounded, color: Colors.white, size: 15),
                                    SizedBox(width: 2),
                                    Text(
                                      'Add',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../domain/models/food_item.dart';
import '../view_models/cart_view_model.dart';
import '../view_models/food_view_model.dart';
import 'app_network_image.dart';

class FoodDetailSheet extends StatefulWidget {
  final FoodItem food;
  final CartViewModel cartViewModel;
  final FoodViewModel foodViewModel;

  const FoodDetailSheet({
    super.key,
    required this.food,
    required this.cartViewModel,
    required this.foodViewModel,
  });

  static void show(
    BuildContext context, {
    required FoodItem food,
    required CartViewModel cartViewModel,
    required FoodViewModel foodViewModel,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FoodDetailSheet(
        food: food,
        cartViewModel: cartViewModel,
        foodViewModel: foodViewModel,
      ),
    );
  }

  @override
  State<FoodDetailSheet> createState() => _FoodDetailSheetState();
}

class _FoodDetailSheetState extends State<FoodDetailSheet> {
  int _quantity = 1;
  String _selectedSize = 'Regular';
  double _sizeExtraPrice = 0.0;

  final Map<String, double> _sizeOptions = {
    'Regular': 0.0,
    'Large (+ ₹50)': 50.0,
    'Gourmet Feast (+ ₹100)': 100.0,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final food = widget.food;
    final isFav = widget.foodViewModel.isFavorite(food.id);

    final currentUnitPrice = food.price + _sizeExtraPrice;
    final totalOrderPrice = currentUnitPrice * _quantity;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF181B20) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            width: 44,
            height: 4.5,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Image
                  Stack(
                    children: [
                      AppNetworkImage(
                        imageUrl: food.imageUrl,
                        height: 220,
                        width: double.infinity,
                        borderRadius: BorderRadius.circular(24),
                        fit: BoxFit.cover,
                        placeholderIcon: Icons.fastfood_rounded,
                        placeholderText: food.name,
                      ),
                      // Close button
                      Positioned(
                        top: 12,
                        left: 12,
                        child: CircleAvatar(
                          backgroundColor: Colors.black54,
                          child: IconButton(
                            icon: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ),
                      // Favorite button
                      Positioned(
                        top: 12,
                        right: 12,
                        child: CircleAvatar(
                          backgroundColor: Colors.black54,
                          child: IconButton(
                            icon: Icon(
                              isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              color: isFav ? theme.colorScheme.primary : Colors.white,
                              size: 20,
                            ),
                            onPressed: () {
                              widget.foodViewModel.toggleFavorite(food.id);
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // Badges Wrap
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          food.category.toUpperCase(),
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (food.isVegetarian)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.eco_rounded, size: 13, color: Colors.green),
                              SizedBox(width: 4),
                              Text(
                                'Vegetarian',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (food.spicyLevel > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '🌶️ ' * food.spicyLevel,
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Title
                  Text(
                    food.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Quick Info Metrics
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF222731) : const Color(0xFFF6F7F9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Color(0xFFFFB300), size: 18),
                            const SizedBox(width: 4),
                            Text(
                              '${food.rating} (${food.reviewCount})',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        Container(height: 18, width: 1, color: isDark ? Colors.white24 : Colors.black12),
                        Row(
                          children: [
                            const Icon(Icons.timer_outlined, color: Colors.grey, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              food.deliveryTime,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        Container(height: 18, width: 1, color: isDark ? Colors.white24 : Colors.black12),
                        Row(
                          children: [
                            const Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              '${food.calories} kcal',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Description
                  const Text(
                    'About this dish',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    food.description,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: isDark ? Colors.white70 : const Color(0xFF4B5563),
                    ),
                  ),
                  if (food.ingredients.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Ingredients & Highlights',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: food.ingredients.map((ing) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF242A35) : const Color(0xFFF0F2F5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '• $ing',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white70 : const Color(0xFF374151),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 20),
                  // Portion Size Selector
                  const Text(
                    'Select Portion',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Column(
                    children: _sizeOptions.entries.map((entry) {
                      final isSelected = _selectedSize == entry.key;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedSize = entry.key;
                              _sizeExtraPrice = entry.value;
                            });
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : (isDark ? const Color(0xFF2C323D) : const Color(0xFFE5E7EB)),
                                width: isSelected ? 1.8 : 1,
                              ),
                              color: isSelected
                                  ? theme.colorScheme.primary.withAlpha(15)
                                  : Colors.transparent,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                  color: isSelected ? theme.colorScheme.primary : Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  entry.key,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          // Sticky Bottom Bar
          Container(
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              MediaQuery.of(context).padding.bottom + 12,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E222A) : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? const Color(0xFF2A303C) : const Color(0xFFE5E7EB),
                ),
              ),
            ),
            child: Row(
              children: [
                // Quantity Counter
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF282F3B) : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 18),
                        onPressed: _quantity > 1
                            ? () => setState(() => _quantity--)
                            : null,
                      ),
                      Text(
                        '$_quantity',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 18),
                        onPressed: () => setState(() => _quantity++),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Add to Cart Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.cartViewModel.addToCart(
                        food,
                        quantity: _quantity,
                        size: _selectedSize.split(' (').first,
                        extraPrice: _sizeExtraPrice,
                      );
                      Navigator.of(context).pop();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFF1F2937),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text('Added $_quantity × ${food.name} to cart!'),
                              ),
                            ],
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Add to Order • ₹${totalOrderPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

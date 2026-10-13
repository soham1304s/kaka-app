import 'package:flutter/material.dart';
import 'package:kaka_app/ui/features/cart/cart_sheet.dart';
import 'package:kaka_app/ui/features/dashboard/dashboard_view.dart';
import 'package:kaka_app/ui/features/profile/profile_view.dart';
import 'package:kaka_app/ui/view_models/auth_view_model.dart';
import 'package:kaka_app/ui/view_models/cart_view_model.dart';
import 'package:kaka_app/ui/view_models/food_view_model.dart';
import 'package:kaka_app/ui/view_models/theme_view_model.dart';
import 'package:kaka_app/ui/widgets/food_card.dart';
import 'package:kaka_app/ui/widgets/food_detail_sheet.dart';

class MainScreen extends StatefulWidget {
  final FoodViewModel foodViewModel;
  final AuthViewModel authViewModel;
  final CartViewModel cartViewModel;
  final ThemeViewModel themeViewModel;

  const MainScreen({
    super.key,
    required this.foodViewModel,
    required this.authViewModel,
    required this.cartViewModel,
    required this.themeViewModel,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void _onTabSelected(int index) {
    if (index == 2) {
      // Open Cart bottom sheet directly
      CartSheet.show(context, cartViewModel: widget.cartViewModel);
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildFavoritesTab() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: widget.foodViewModel,
      builder: (context, _) {
        final allItems = widget.foodViewModel.filteredItems;
        final favItems = allItems
            .where((item) => widget.foodViewModel.isFavorite(item.id))
            .toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('My Favorites'),
          ),
          body: favItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('❤️', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 12),
                      const Text(
                        'No favorites yet',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tap the heart icon on any food item to save it here.',
                        style: TextStyle(fontSize: 13, color: isDark ? Colors.white60 : Colors.grey),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 90),
                  child: GridView.builder(
                    itemCount: favItems.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.68,
                    ),
                    itemBuilder: (context, index) {
                      final food = favItems[index];
                      return FoodCard(
                        food: food,
                        isFavorite: true,
                        onTap: () => FoodDetailSheet.show(
                          context,
                          food: food,
                          cartViewModel: widget.cartViewModel,
                          foodViewModel: widget.foodViewModel,
                        ),
                        onFavoriteToggle: () => widget.foodViewModel.toggleFavorite(food.id),
                        onAddToCart: () {
                          widget.cartViewModel.addToCart(food);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: const Color(0xFF1F2937),
                              behavior: SnackBarBehavior.floating,
                              content: Text('Added ${food.name} to cart'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final pages = [
      DashboardView(
        foodViewModel: widget.foodViewModel,
        authViewModel: widget.authViewModel,
        cartViewModel: widget.cartViewModel,
        themeViewModel: widget.themeViewModel,
        onNavigateToProfile: () => setState(() => _selectedIndex = 3),
      ),
      _buildFavoritesTab(),
      const SizedBox.shrink(), // Placeholder for Cart action
      ProfileView(
        authViewModel: widget.authViewModel,
        themeViewModel: widget.themeViewModel,
        foodViewModel: widget.foodViewModel,
        cartViewModel: widget.cartViewModel,
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: pages,
          ),
          // Floating Cart Snack Pill when cart has items and on dashboard
          if (_selectedIndex == 0)
            ListenableBuilder(
              listenable: widget.cartViewModel,
              builder: (context, _) {
                if (widget.cartViewModel.isEmpty) return const SizedBox.shrink();

                return Positioned(
                  left: 20,
                  right: 20,
                  bottom: 78,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => CartSheet.show(context, cartViewModel: widget.cartViewModel),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF4B26), Color(0xFFFF6945)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF4B26).withAlpha(100),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(50),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${widget.cartViewModel.itemCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'View Cart & Checkout',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Text(
                              '₹${widget.cartViewModel.total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 14),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF16191E) : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF262C36) : const Color(0xFFEEEEEE),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: _buildNavItem(
                    index: 0,
                    icon: Icons.storefront_outlined,
                    activeIcon: Icons.storefront_rounded,
                    label: 'Explore',
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    index: 1,
                    icon: Icons.favorite_outline_rounded,
                    activeIcon: Icons.favorite_rounded,
                    label: 'Favorites',
                  ),
                ),
                Expanded(child: _buildCartNavItem()),
                Expanded(
                  child: _buildNavItem(
                    index: 3,
                    icon: Icons.person_outline_rounded,
                    activeIcon: Icons.person_rounded,
                    label: 'Profile',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = _selectedIndex == index;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onTabSelected(index),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withAlpha(20)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                color: isSelected
                    ? theme.colorScheme.primary
                    : (isDark ? Colors.white60 : const Color(0xFF6B7280)),
                size: 22,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : (isDark ? Colors.white60 : const Color(0xFF6B7280)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartNavItem() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: widget.cartViewModel,
      builder: (context, _) {
        final count = widget.cartViewModel.itemCount;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _onTabSelected(2),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Badge(
                    isLabelVisible: count > 0,
                    backgroundColor: theme.colorScheme.primary,
                    label: Text(
                      '$count',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      color: isDark ? Colors.white60 : const Color(0xFF6B7280),
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Cart',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white60 : const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

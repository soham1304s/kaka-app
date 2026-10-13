import 'package:flutter/material.dart';
import 'package:kaka_app/ui/features/auth/auth_page.dart';
import 'package:kaka_app/ui/view_models/auth_view_model.dart';
import 'package:kaka_app/ui/view_models/cart_view_model.dart';
import 'package:kaka_app/ui/view_models/food_view_model.dart';
import 'package:kaka_app/ui/view_models/theme_view_model.dart';
import 'package:kaka_app/ui/widgets/app_network_image.dart';
import 'package:kaka_app/ui/widgets/auth_card.dart';
import 'package:kaka_app/ui/widgets/category_bar.dart';
import 'package:kaka_app/ui/widgets/food_card.dart';
import 'package:kaka_app/ui/widgets/food_detail_sheet.dart';
import 'package:kaka_app/ui/widgets/promo_carousel.dart';

class DashboardView extends StatefulWidget {
  final FoodViewModel foodViewModel;
  final AuthViewModel authViewModel;
  final CartViewModel cartViewModel;
  final ThemeViewModel? themeViewModel;
  final VoidCallback onNavigateToProfile;

  const DashboardView({
    super.key,
    required this.foodViewModel,
    required this.authViewModel,
    required this.cartViewModel,
    this.themeViewModel,
    required this.onNavigateToProfile,
  });

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAuthPage({bool isSignUp = false}) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, anim, secAnim) => AuthPage(
          authViewModel: widget.authViewModel,
          foodViewModel: widget.foodViewModel,
          cartViewModel: widget.cartViewModel,
          themeViewModel: widget.themeViewModel ?? ThemeViewModel(),
          initialIsSignUp: isSignUp,
        ),
        transitionsBuilder: (context, anim, secAnim, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  void _showSortDialog() {
    final currentSort = widget.foodViewModel.sortBy;
    final options = [
      'Popular',
      'Rating',
      'Price: Low to High',
      'Price: High to Low',
      'Fastest Delivery',
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    'Sort Items By',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
                ...options.map((option) {
                  final isSelected = currentSort == option;
                  return ListTile(
                    title: Text(
                      option,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Theme.of(context).colorScheme.primary : null,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_rounded, color: Theme.of(context).colorScheme.primary)
                        : null,
                    onTap: () {
                      widget.foodViewModel.setSortBy(option);
                      Navigator.of(ctx).pop();
                    },
                  );
                }),
              ],
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

    return ListenableBuilder(
      listenable: Listenable.merge([widget.foodViewModel, widget.authViewModel, widget.cartViewModel]),
      builder: (context, _) {
        final items = widget.foodViewModel.filteredItems;
        final user = widget.authViewModel.currentUser;
        final isAuth = widget.authViewModel.isAuthenticated && user != null;

        return Scaffold(
          body: SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: [
                // Top App Bar / Location & User Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Location Delivery
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.near_me_rounded,
                                    size: 15,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'DELIVER TO',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.6,
                                      color: isDark ? Colors.white60 : const Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      isAuth ? user.address : '742 Park Street, Indiranagar, Bengaluru',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Right Actions: Notification & Avatar
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF22262E) : Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark ? const Color(0xFF2E3440) : const Color(0xFFE5E7EB),
                                ),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.notifications_none_rounded, size: 22),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('No new notifications right now.'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: isAuth
                                  ? widget.onNavigateToProfile
                                  : () => _openAuthPage(isSignUp: false),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: theme.colorScheme.primary,
                                    width: 1.8,
                                  ),
                                ),
                                child: ClipOval(
                                  child: SizedBox(
                                    width: 36,
                                    height: 36,
                                    child: isAuth
                                        ? AppNetworkImage(
                                            imageUrl: user.avatarUrl,
                                            placeholderIcon: Icons.person_rounded,
                                          )
                                        : Container(
                                            color: theme.colorScheme.primary.withAlpha(20),
                                            child: Icon(Icons.person_rounded, color: theme.colorScheme.primary, size: 20),
                                          ),
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

                // Search Bar & Filter Button
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E222A) : Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isDark ? const Color(0xFF2C323E) : const Color(0xFFE5E7EB),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(6),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (val) => widget.foodViewModel.setSearchQuery(val),
                              decoration: InputDecoration(
                                hintText: 'Search food, pizza, burgers, etc...',
                                prefixIcon: const Icon(Icons.search_rounded, size: 22),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear_rounded, size: 18),
                                        onPressed: () {
                                          _searchController.clear();
                                          widget.foodViewModel.setSearchQuery('');
                                        },
                                      )
                                    : null,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Sort / Filter Button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _showSortDialog,
                            borderRadius: BorderRadius.circular(18),
                            child: Container(
                              padding: const EdgeInsets.all(13),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.primary.withAlpha(60),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.tune_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 14)),

                // AUTH SECTION ON DASHBOARD (Required by prompt: "add a auth section also in the dashboard")
                SliverToBoxAdapter(
                  child: AuthCard(
                    authViewModel: widget.authViewModel,
                    onOpenAuth: () => _openAuthPage(isSignUp: false),
                    onOpenProfile: widget.onNavigateToProfile,
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 18)),

                // Promotional Banners Carousel
                SliverToBoxAdapter(
                  child: PromoCarousel(
                    banners: widget.foodViewModel.promoBanners,
                    onBannerTap: (banner) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFF1F2937),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          content: Text('Promo Code: ${banner.discountCode} applied to your checkout!'),
                        ),
                      );
                    },
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 18)),

                // Categories Bar
                SliverToBoxAdapter(
                  child: CategoryBar(
                    categories: widget.foodViewModel.categories,
                    selectedCategory: widget.foodViewModel.selectedCategory,
                    onSelectCategory: (cat) => widget.foodViewModel.selectCategory(cat),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                // Section Title & Items Count
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            widget.foodViewModel.selectedCategory == 'All'
                                ? 'Gourmet Delicacies'
                                : widget.foodViewModel.selectedCategory,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF232731) : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${items.length} dishes',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : const Color(0xFF4B5563),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 12)),

                // Food Items Grid (Responsive)
                if (items.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Column(
                          children: [
                            const Text('🍽️', style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 12),
                            const Text(
                              'No food items found',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Try adjusting your search query or filter category.',
                              style: TextStyle(fontSize: 13, color: isDark ? Colors.white60 : Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 90),
                    sliver: SliverLayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount = constraints.crossAxisExtent > 700 ? 3 : 2;
                        final childAspectRatio = constraints.crossAxisExtent < 380 ? 0.60 : 0.64;
                        return SliverGrid(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: childAspectRatio,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final food = items[index];
                              final isFav = widget.foodViewModel.isFavorite(food.id);

                              return FoodCard(
                                food: food,
                                isFavorite: isFav,
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
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      content: Row(
                                        children: [
                                          const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
                                          const SizedBox(width: 8),
                                          Text('Added ${food.name} to cart'),
                                        ],
                                      ),
                                      duration: const Duration(milliseconds: 1400),
                                    ),
                                  );
                                },
                              );
                            },
                            childCount: items.length,
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

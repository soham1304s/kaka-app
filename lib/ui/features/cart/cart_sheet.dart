import 'package:flutter/material.dart';
import '../../view_models/cart_view_model.dart';
import 'package:kaka_app/ui/widgets/app_network_image.dart';

class CartSheet extends StatelessWidget {
  final CartViewModel cartViewModel;

  const CartSheet({
    super.key,
    required this.cartViewModel,
  });

  static void show(BuildContext context, {required CartViewModel cartViewModel}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CartSheet(cartViewModel: cartViewModel),
    );
  }

  void _showCheckoutSuccess(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF10B981),
                size: 54,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Order Placed Successfully!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your chef is preparing your gourmet meal. Track live progress in your profile.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                cartViewModel.clearCart();
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Back to Menu'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: cartViewModel,
      builder: (context, _) {
        final items = cartViewModel.items;

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.88,
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF181B20) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    const Text(
                      'My Cart',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withAlpha(25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${cartViewModel.itemCount} items',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (items.isNotEmpty)
                      TextButton(
                        onPressed: () => cartViewModel.clearCart(),
                        child: const Text('Clear All', style: TextStyle(color: Colors.red)),
                      ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Items List or Empty State
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🛒', style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 12),
                            const Text(
                              'Your cart is empty',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Explore appetizing food items in the dashboard\nand add your favorites!',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 13, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: items.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E222A) : Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isDark ? const Color(0xFF2C323E) : const Color(0xFFEFF0F3),
                              ),
                            ),
                            child: Row(
                              children: [
                                AppNetworkImage(
                                  imageUrl: item.food.imageUrl,
                                  width: 65,
                                  height: 65,
                                  borderRadius: BorderRadius.circular(14),
                                  fit: BoxFit.cover,
                                  placeholderIcon: Icons.fastfood_rounded,
                                  placeholderText: item.food.name,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.food.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        'Portion: ${item.selectedSize}',
                                        style: const TextStyle(fontSize: 11.5, color: Colors.grey),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '₹${item.totalPrice.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Quantity selector
                                Container(
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF282F3B) : const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove, size: 16),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                        onPressed: () => cartViewModel.updateQuantity(item, -1),
                                      ),
                                      Text(
                                        '${item.quantity}',
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add, size: 16),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                        onPressed: () => cartViewModel.updateQuantity(item, 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),

              // Bottom Checkout Panel
              if (items.isNotEmpty)
                Container(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    16,
                    20,
                    MediaQuery.of(context).padding.bottom + 12,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E222A) : Colors.white,
                    border: Border(
                      top: BorderSide(
                        color: isDark ? const Color(0xFF2B313C) : const Color(0xFFE5E7EB),
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Subtotal
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal', style: TextStyle(fontSize: 13, color: Colors.grey)),
                          Text('₹${cartViewModel.subtotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Delivery
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Delivery Fee', style: TextStyle(fontSize: 13, color: Colors.grey)),
                          Text(
                            cartViewModel.deliveryFee == 0 ? 'FREE' : '₹${cartViewModel.deliveryFee.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: cartViewModel.deliveryFee == 0 ? Colors.green : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Tax
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Taxes & Charges (GST)', style: TextStyle(fontSize: 13, color: Colors.grey)),
                          Text('₹${cartViewModel.tax.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Divider(height: 1),
                      const SizedBox(height: 10),
                      // Total
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Amount', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                          Text(
                            '₹${cartViewModel.total.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _showCheckoutSuccess(context),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(
                            'Checkout • ₹${cartViewModel.total.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

import 'food_item.dart';

class CartItem {
  final FoodItem food;
  final int quantity;
  final String selectedSize;
  final double extraPricePerSize;

  const CartItem({
    required this.food,
    required this.quantity,
    this.selectedSize = 'Regular',
    this.extraPricePerSize = 0.0,
  });

  double get unitPrice => food.price + extraPricePerSize;
  double get totalPrice => unitPrice * quantity;

  CartItem copyWith({
    FoodItem? food,
    int? quantity,
    String? selectedSize,
    double? extraPricePerSize,
  }) {
    return CartItem(
      food: food ?? this.food,
      quantity: quantity ?? this.quantity,
      selectedSize: selectedSize ?? this.selectedSize,
      extraPricePerSize: extraPricePerSize ?? this.extraPricePerSize,
    );
  }
}

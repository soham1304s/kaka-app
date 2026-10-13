import 'package:flutter/foundation.dart';
import '../../domain/models/cart_item.dart';
import '../../domain/models/food_item.dart';

class CartViewModel extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get deliveryFee => subtotal > 499.0 || _items.isEmpty ? 0.0 : 49.00;

  double get tax => subtotal * 0.05;

  double get total => subtotal + deliveryFee + tax;

  bool get isEmpty => _items.isEmpty;

  void addToCart(
    FoodItem food, {
    int quantity = 1,
    String size = 'Regular',
    double extraPrice = 0.0,
  }) {
    final existingIndex = _items.indexWhere(
      (element) => element.food.id == food.id && element.selectedSize == size,
    );

    if (existingIndex != -1) {
      final existing = _items[existingIndex];
      _items[existingIndex] = existing.copyWith(
        quantity: existing.quantity + quantity,
      );
    } else {
      _items.add(
        CartItem(
          food: food,
          quantity: quantity,
          selectedSize: size,
          extraPricePerSize: extraPrice,
        ),
      );
    }
    notifyListeners();
  }

  void updateQuantity(CartItem item, int delta) {
    final index = _items.indexOf(item);
    if (index == -1) return;

    final newQty = item.quantity + delta;
    if (newQty <= 0) {
      _items.removeAt(index);
    } else {
      _items[index] = item.copyWith(quantity: newQty);
    }
    notifyListeners();
  }

  void removeItem(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import '../models/cart_item.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> cartItems = [];

  double shippingFee = 5;
  double discount = 0;

  String address = '';
  String paymentMethod = '';

  void addToCart(CartItem item) {
    int existingIndex =
    cartItems.indexWhere((e) => e.id == item.id);

    if (existingIndex >= 0) {
      cartItems[existingIndex].quantity++;
    } else {
      cartItems.add(item);
    }

    notifyListeners();
  }

  void incrementQuantity(String id) {
    int index = cartItems.indexWhere((e) => e.id == id);

    cartItems[index].quantity++;

    notifyListeners();
  }

  void decrementQuantity(String id) {
    int index = cartItems.indexWhere((e) => e.id == id);

    if (cartItems[index].quantity > 1) {
      cartItems[index].quantity--;
    } else {
      cartItems.removeAt(index);
    }

    notifyListeners();
  }

  double get subtotal {
    double total = 0;

    for (var item in cartItems) {
      total += item.price * item.quantity;
    }

    return total;
  }

  double get tax => subtotal * 0.10;

  double get total =>
      subtotal + tax + shippingFee - discount;

  void applyDiscountCode(String code) {
    if (code == 'SAVE10') {
      discount = 10;
    } else {
      discount = 0;
    }

    notifyListeners();
  }

  void saveAddress(String value) {
    address = value;
    notifyListeners();
  }

  void savePaymentMethod(String value) {
    paymentMethod = value;
    notifyListeners();
  }

  void clearCart() {
    cartItems.clear();
    discount = 0;
    notifyListeners();
  }
}

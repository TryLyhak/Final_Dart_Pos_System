import 'package:pos_frontend/models/cart_item.dart';
import 'package:pos_frontend/models/product.dart';
import 'package:pos_frontend/utils/exceptions.dart';

class Cart {
  List<CartItem> items = [];

  // Add product to cart
  void addProduct({required Product product, required int quantity}) {
    final existing = _findById(product.id!);
    if (existing != null) {
      existing.quantity += quantity;
    } else {
      items.add(CartItem(product: product, quantity: quantity));
    }
  }

  // Update quantity
  void updateQuantity({required int productId, required int newQuantity}) {
    final item = _findById(productId);
    if (item == null) {
      throw ValidationException(
        message: 'Product ID $productId is not in cart.',
      );
    }
    item.quantity = newQuantity;
  }

  // Remove product from cart
  void removeProduct({required int productId}) {
    final item = _findById(productId);
    if (item == null) {
      throw ValidationException(
        message: 'Product ID $productId is not in cart.',
      );
    }
    items.removeWhere((cartitem) => cartitem.product.id == productId);
  }

  // Clear all items
  void clear() => items.clear();

  // Calculate grand total
  double get total => items.fold(0, (sum, item) => sum + item.subtotal);

  // Check if cart is empty
  bool get isEmpty => items.isEmpty;

  // Get item count
  int get itemCount => items.length;

  // Private helper — find item by product ID
  CartItem? _findById(int productId) {
    for (final item in items) {
      if (item.product.id == productId) {
        return item;
      }
    }
    return null;
  }
}

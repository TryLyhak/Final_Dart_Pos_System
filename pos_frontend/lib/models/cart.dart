import 'package:pos_frontend/models/cart_item.dart';
import 'package:pos_frontend/models/product.dart';

class Cart {
  // Private list — only accessible through Cart methods
  final List<CartItem> _items = [];

  // Public read-only access to items
  List<CartItem> get items => List.unmodifiable(_items);

  // ── Add product or increase qty if already in cart ────────
  void addProduct({required Product product, required int quantity}) {
    final existing = _findById(product.id!);
    if (existing != null) {
      // Product already in cart — just increase quantity
      existing.quantity += quantity;
    } else {
      // New product — add to cart
      _items.add(CartItem(product: product, quantity: quantity));
    }
  }

  // ── Update quantity of an existing cart item ──────────────
  void updateQuantity({required int productId, required int newQuantity}) {
    final item = _findById(productId);
    if (item != null && newQuantity > 0) {
      item.quantity = newQuantity;
    }
  }

  // ── Remove a specific product from cart ───────────────────
  void removeProduct({required int productId}) {
    _items.removeWhere((item) => item.product.id == productId);
  }

  // ── Clear all cart items ──────────────────────────────────
  void clear() => _items.clear();

  // ── Calculate grand total ─────────────────────────────────
  double get total => _items.fold(0, (sum, item) => sum + item.subtotal);

  // ── Check if cart is empty ────────────────────────────────
  bool get isEmpty => _items.isEmpty;

  // ── Check if cart has items ───────────────────────────────
  bool get isNotEmpty => _items.isNotEmpty;

  // ── Get item count ────────────────────────────────────────
  int get itemCount => _items.length;

  // ── Print all cart items in a formatted table ─────────────
  void printCart() {
    if (isEmpty) {
      print('  Cart is empty.');
      return;
    }
    print(
      '  ${'ID'.padRight(6)}'
      '${'Product'.padRight(22)}'
      '${'Qty'.padRight(6)}'
      'Subtotal',
    );
    print('  ${'─' * 42}');
    for (final item in _items) {
      item.printRow();
    }
    print('  ${'─' * 42}');
    print('  TOTAL: \$${total.toStringAsFixed(2)}');
  }

  // ── Convert cart to API-ready JSON list for checkout ──────
  List<Map<String, dynamic>> toOrderPayload() {
    return _items
        .map(
          (item) => {'product_id': item.product.id, 'quantity': item.quantity},
        )
        .toList();
  }

  // ── Private helper — find CartItem by product ID ──────────
  CartItem? _findById(int productId) {
    try {
      return _items.firstWhere((i) => i.product.id == productId);
    } catch (_) {
      return null;
    }
  }
}

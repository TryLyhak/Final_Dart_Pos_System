import 'package:pos_frontend/models/category.dart';
import 'package:pos_frontend/models/product.dart';
import 'package:pos_frontend/models/cart.dart';
import 'package:pos_frontend/models/order.dart';
import 'package:pos_frontend/services/api_services.dart';
import 'package:pos_frontend/utils/exceptions.dart';
import 'package:pos_frontend/utils/input.dart';

// ProductService — handles ALL product, category and order API calls
// Matches teacher's requirement — one service only!

class ProductService {
  // Instance of ApiService — matches teacher's style
  final ApiService _apiService = ApiService();

  // ✅ Local list — matches teacher's sample style!
  List<Product> products = [];

  // ══════════════════════════════════════════════
  // PRODUCT METHODS
  // ══════════════════════════════════════════════

  // Get all products
  Future<List<Product>> getAllProducts() async {
    try {
      final response = await _apiService.get('/products');
      final list = response['data'] as List<dynamic>;

      // ✅ Store in local list — matches teacher style!
      products = list
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();

      return products;
    } on ApiException {
      rethrow;
    }
  }

  //  Get single product by ID
  Future<Product> getProductById({required int id}) async {
    validateId(id, fieldName: 'Product ID');

    try {
      final response = await _apiService.get('/products?id=$id');
      return Product.fromJson(response['data'] as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    }
  }

  // Search products
  Future<List<Product>> searchProducts({required String keyword}) async {
    final query = validateSearchKeyword(keyword);

    try {
      final response = await _apiService.get('/products?search=$query');
      final list = response['data'] as List<dynamic>;
      return list
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();
    } on ApiException {
      rethrow;
    }
  }

  // Create product
  Future<void> createProduct({
    required String productName,
    required double price,
    required int stock,
    required int categoryId,
  }) async {
    final trimmedName = validateRequiredText(
      productName,
      fieldName: 'Product name',
    );
    validatePositiveDouble(price, fieldName: 'Product price');
    validateNonNegativeInt(stock, fieldName: 'Stock quantity');
    validateId(categoryId, fieldName: 'Category ID');

    try {
      await _apiService.post('/products', {
        'category_id': categoryId,
        'product_name': trimmedName,
        'price': price,
        'stock': stock,
      });
    } on ApiException {
      rethrow;
    }
  }

  // Update product
  Future<void> updateProduct({
    required int id,
    required String productName,
    required double price,
    required int stock,
    required int categoryId,
  }) async {
    validateId(id, fieldName: 'Product ID');
    final trimmedName = validateRequiredText(
      productName,
      fieldName: 'Product name',
    );
    validatePositiveDouble(price, fieldName: 'Product price');
    validateNonNegativeInt(stock, fieldName: 'Stock quantity');
    validateId(categoryId, fieldName: 'Category ID');

    try {
      await _apiService.put('/products?id=$id', {
        'product_name': trimmedName,
        'price': price,
        'stock': stock,
        'category_id': categoryId,
      });
    } on ApiException {
      rethrow;
    }
  }

  // Delete product
  Future<void> deleteProduct({required int id}) async {
    // ✅ Dart validates ID
    if (id <= 0) {
      throw ValidationException(message: 'Invalid product ID.');
    }

    try {
      await _apiService.delete('/products?id=$id');
    } on ApiException {
      rethrow;
    }
  }

  // Manage stock
  Future<void> manageStock({
    required int id,
    required String productName,
    required double price,
    required int newStock,
    required int categoryId,
  }) async {
    validateId(id, fieldName: 'Product ID');
    validateRequiredText(productName, fieldName: 'Product name');
    validatePositiveDouble(price, fieldName: 'Product price');
    validateNonNegativeInt(newStock, fieldName: 'Stock quantity');
    validateId(categoryId, fieldName: 'Category ID');

    try {
      await _apiService.put('/products?id=$id', {
        'product_name': productName,
        'price': price,
        'stock': newStock,
        'category_id': categoryId,
      });
    } on ApiException {
      rethrow;
    }
  }

  // ══════════════════════════════════════════════
  // CATEGORY METHODS
  // ══════════════════════════════════════════════

  // ── Get all categories ─────────────────────
  Future<List<Category>> getAllCategories() async {
    try {
      final response = await _apiService.get('/categories');
      final list = response['data'] as List<dynamic>;
      return list
          .map((json) => Category.fromJson(json as Map<String, dynamic>))
          .toList();
    } on ApiException {
      rethrow;
    }
  }

  // ══════════════════════════════════════════════
  // ORDER METHODS
  // ══════════════════════════════════════════════

  // ── Checkout — submit cart to API ──────────
  Future<Map<String, dynamic>> checkout({
    required Cart cart,
    required int userId,
  }) async {
    if (cart.isEmpty) {
      throw ValidationException(message: 'Cart cannot be empty.');
    }
    validateId(userId, fieldName: 'User ID');

    final items = cart.items.map((item) {
      final productId = item.product.id;
      if (productId == null) {
        throw ValidationException(message: 'Cart contains an invalid product.');
      }
      validateId(productId, fieldName: 'Product ID');
      validatePositiveInt(item.quantity, fieldName: 'Quantity');

      return {'product_id': productId, 'quantity': item.quantity};
    }).toList();

    try {
      final response = await _apiService.post('/orders', {
        'user_id': userId,
        'items': items,
      });

      return response['data'] as Map<String, dynamic>;
    } on ApiException {
      rethrow;
    }
  }

  // ── Get all orders ─────────────────────────
  Future<List<Order>> getAllOrders() async {
    try {
      final response = await _apiService.get('/orders');
      final list = response['data'] as List<dynamic>;
      return list
          .map((json) => Order.fromJson(json as Map<String, dynamic>))
          .toList();
    } on ApiException {
      rethrow;
    }
  }

  // Get order receipt
  Future<Order> getOrderReceipt({required int orderId}) async {
    // ✅ Dart validates ID
    if (orderId <= 0) {
      throw ValidationException(message: 'Invalid order ID.');
    }

    try {
      final response = await _apiService.get('/orders?id=$orderId');
      return Order.fromJson(response['data'] as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    }
  }
}

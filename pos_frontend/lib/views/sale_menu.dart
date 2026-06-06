import 'package:pos_frontend/models/cart.dart';
import 'package:pos_frontend/services/auth_services.dart';
import 'package:pos_frontend/services/product_service.dart';
import 'package:pos_frontend/utils/input.dart';
import 'package:pos_frontend/utils/exceptions.dart';
import 'package:pos_frontend/utils/table_view.dart';

// Sale Menu — handles all sale features + local cart
// Receives instances from App class

Future<void> showSaleMenu({
  required AuthService authService,
  required ProductService productService,
  required TableView tableView,
}) async {
  final name = authService.currentName;

  // ✅ Local cart — lives in memory only!
  final cart = Cart();

  while (true) {
    printHeader('🛒 SALE MENU — Welcome, $name');
    print('  1.  Display All Products');
    print('  2.  View Product Details');
    print('  3.  Search Products');
    print('  4.  Add to Cart');
    print('  5.  View Cart');
    print('  6.  Update Cart Quantity');
    print('  7.  Remove from Cart');
    print('  8.  Clear Cart');
    print('  9.  Calculate Total');
    print('  10. Checkout');
    print('  11. View Order History');
    print('  12. View Receipt');
    print('  0.  Logout');
    printDivider();

    final choice = readInt(prompt: '  Enter choice: ');

    try {
      switch (choice) {
        case 1:
          await _displayAllProducts(productService, tableView);
          break;
        case 2:
          await _viewProductDetails(productService, tableView);
          break;
        case 3:
          await _searchProducts(productService, tableView);
          break;
        case 4:
          await _addToCart(productService, tableView, cart);
          break;
        case 5:
          _viewCart(tableView, cart);
          break;
        case 6:
          _updateCartQty(tableView, cart);
          break;
        case 7:
          _removeFromCart(tableView, cart);
          break;
        case 8:
          _clearCart(cart);
          break;
        case 9:
          _calculateTotal(tableView, cart);
          break;
        case 10:
          await _checkout(productService, tableView, authService, cart);
          break;
        case 11:
          await _viewOrderHistory(productService, tableView);
          break;
        case 12:
          await _viewReceipt(productService, tableView);
          break;
        case 0:
          await authService.logout();
          print('\n  ✅ Logged out successfully. Goodbye, $name!\n');
          return;
        default:
          print('  ⚠ Invalid option. Please try again.');
      }
    } on ValidationException catch (e) {
      print('  ⚠ Validation: ${e.message}');
    } on ApiException catch (e) {
      print(' API Error: ${e.message}');
    } catch (e) {
      print(' Unexpected error: $e');
    }
  }
}

// 1. Display All Products
Future<void> _displayAllProducts(
  ProductService productService,
  TableView tableView,
) async {
  print('\n  Fetching products...');
  final products = await productService.getAllProducts();

  printHeader('AVAILABLE PRODUCTS');
  tableView.displayProducts(products);
}

// 2. View Product Details
Future<void> _viewProductDetails(
  ProductService productService,
  TableView tableView,
) async {
  final id = readInt(prompt: '  Enter Product ID: ', min: 1);
  final p = await productService.getProductById(id: id);

  printHeader('PRODUCT DETAILS');
  tableView.printTable(
    ['Field', 'Value'],
    [
      ['ID', p.id.toString()],
      ['Name', p.name],
      ['Category', p.categoryName ?? ''],
      ['Price', '\$${p.price?.toStringAsFixed(2)}'],
      ['Stock', p.stock.toString()],
    ],
    numericColumns: [false, false],
  );
}

// 3. Search Products
Future<void> _searchProducts(
  ProductService productService,
  TableView tableView,
) async {
  final keyword = readString(prompt: '  Search keyword: ');
  final products = await productService.searchProducts(keyword: keyword);

  printHeader('SEARCH RESULTS — "$keyword"');
  tableView.displayProducts(products);
}

// 4. Add to Cart
Future<void> _addToCart(
  ProductService productService,
  TableView tableView,
  Cart cart,
) async {
  await _displayAllProducts(productService, tableView);

  final id = readInt(prompt: '\n  Product ID to add : ', min: 1);
  final qty = readInt(prompt: '  Quantity          : ', min: 1);

  final product = await productService.getProductById(id: id);

  // ✅ Dart validates stock
  if (qty > (product.stock ?? 0)) {
    throw ValidationException(
      message: 'Not enough stock. Available: ${product.stock}',
    );
  }

  // ✅ Add to local cart — no API call!
  cart.addProduct(product: product, quantity: qty);

  // Show confirmation
  tableView.printTable(
    ['Product', 'Qty', 'Unit Price', 'Subtotal'],
    [
      [
        product.name,
        qty.toString(),
        '\$${product.price?.toStringAsFixed(2)}',
        '\$${((product.price ?? 0) * qty).toStringAsFixed(2)}',
      ],
    ],
    numericColumns: [false, true, true, true],
  );
  print('  ✅ Added to cart successfully!');
}

// 5. View Cart
void _viewCart(TableView tableView, Cart cart) {
  printHeader('YOUR CART');
  tableView.displayCart(cart);
}

// 6. Update Cart Quantity
void _updateCartQty(TableView tableView, Cart cart) {
  if (cart.isEmpty) {
    print('  ⚠ Cart is empty. Add items first.');
    return;
  }

  printHeader('UPDATE CART QUANTITY');
  tableView.displayCart(cart);

  final id = readInt(prompt: '\n  Product ID to update : ', min: 1);
  final qty = readInt(prompt: '  New quantity         : ', min: 1);

  cart.updateQuantity(productId: id, newQuantity: qty);
  print('  ✅ Quantity updated successfully.');
}

// 7. Remove from Cart
void _removeFromCart(TableView tableView, Cart cart) {
  if (cart.isEmpty) {
    print('  ⚠ Cart is empty. Nothing to remove.');
    return;
  }

  printHeader('REMOVE FROM CART');
  tableView.displayCart(cart);

  final id = readInt(prompt: '\n  Product ID to remove : ', min: 1);
  cart.removeProduct(productId: id);
  print('  ✅ Item removed from cart.');
}

// 8. Clear Cart
void _clearCart(Cart cart) {
  if (cart.isEmpty) {
    print('  ⚠ Cart is already empty.');
    return;
  }

  final confirm = readYesNo(prompt: '  Clear entire cart?');

  if (confirm) {
    cart.clear();
    print('  ✅ Cart cleared successfully.');
  } else {
    print('  Cancelled.');
  }
}

// 9. Calculate Total
void _calculateTotal(TableView tableView, Cart cart) {
  printHeader('CALCULATE TOTAL');

  if (cart.isEmpty) {
    print('  ⚠ Cart is empty. Add items first.');
    return;
  }

  // Show itemized table
  tableView.printTable(
    ['Product Name', 'Unit Price', 'Qty', 'Subtotal'],
    cart.items
        .map(
          (item) => [
            item.product.name,
            '\$${item.product.price?.toStringAsFixed(2)}',
            item.quantity.toString(),
            '\$${item.subtotal.toStringAsFixed(2)}',
          ],
        )
        .toList(),
    numericColumns: [false, true, true, true],
  );

  // ✅ Show total — Dart calculates!
  print('\n  ┌─────────────────────────────────┐');
  print('  │  Items  : ${cart.itemCount.toString().padLeft(10)}           │');
  print(
    '  │  TOTAL  : \$${cart.total.toStringAsFixed(2).padLeft(9)}           │',
  );
  print('  └─────────────────────────────────┘');
}

// 10. Checkout
Future<void> _checkout(
  ProductService productService,
  TableView tableView,
  AuthService authService,
  Cart cart,
) async {
  printHeader('CHECKOUT SUMMARY');

  // Show cart
  tableView.printTable(
    ['Product Name', 'Unit Price', 'Qty', 'Subtotal'],
    cart.items
        .map(
          (item) => [
            item.product.name,
            '\$${item.product.price?.toStringAsFixed(2)}',
            item.quantity.toString(),
            '\$${item.subtotal.toStringAsFixed(2)}',
          ],
        )
        .toList(),
    numericColumns: [false, true, true, true],
  );

  print('\n  Items : ${cart.itemCount}');
  print('  Total : \$${cart.total.toStringAsFixed(2)}');

  final confirm = readYesNo(prompt: '  Confirm order?');
  if (!confirm) {
    print('  Cancelled.');
    return;
  }

  print('\n  Processing order...');

  // ✅ Send cart + user_id to API — no token!
  final result = await productService.checkout(
    cart: cart,
    userId: authService.currentUser!.id!,
  );

  // ✅ Clear local cart after successful order
  cart.clear();

  printHeader('✅ ORDER PLACED SUCCESSFULLY');
  tableView.printTable(
    ['Field', 'Value'],
    [
      ['Order ID', result['order_id'].toString()],
      ['Total', '\$${result['total']}'],
      ['Status', 'Completed'],
    ],
    numericColumns: [false, false],
  );
}

// 11. View Order History
Future<void> _viewOrderHistory(
  ProductService productService,
  TableView tableView,
) async {
  print('\n  Fetching order history...');
  final orders = await productService.getAllOrders();

  printHeader('ORDER HISTORY');
  tableView.displayOrders(orders);
}

// 12. View Receipt
Future<void> _viewReceipt(
  ProductService productService,
  TableView tableView,
) async {
  final id = readInt(prompt: '  Enter Order ID: ');
  final order = await productService.getOrderReceipt(orderId: id);

  printHeader('RECEIPT — Order #${order.id}');
  tableView.displayReceipt(order);
}

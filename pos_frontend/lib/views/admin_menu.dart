import 'package:pos_frontend/services/auth_services.dart';
import 'package:pos_frontend/services/product_service.dart';
import 'package:pos_frontend/utils/input.dart';
import 'package:pos_frontend/utils/exceptions.dart';
import 'package:pos_frontend/utils/table_view.dart';

// Admin Menu — handles all admin features
// Receives instances from App class

Future<void> showAdminMenu({
  required AuthService authService,
  required ProductService productService,
  required TableView tableView,
}) async {
  final name = authService.currentName;

  while (true) {
    printHeader('ADMIN MENU — Welcome, $name');
    print('  1.  Display All Products');
    print('  2.  View Product Details');
    print('  3.  Search Products');
    print('  4.  Add New Product');
    print('  5.  Update Product');
    print('  6.  Delete Product');
    print('  7.  Manage Stock');
    print('  8.  View All Categories');
    print('  9.  View All Orders');
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
          await _addProduct(productService, tableView);
          break;
        case 5:
          await _updateProduct(productService, tableView);
          break;
        case 6:
          await _deleteProduct(productService, tableView);
          break;
        case 7:
          await _manageStock(productService, tableView);
          break;
        case 8:
          await _viewAllCategories(productService, tableView);
          break;
        case 9:
          await _viewAllOrders(productService, tableView);
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
      print('  ❌ API Error: ${e.message}');
    } catch (e) {
      print('  ❌ Unexpected error: $e');
    }
  }
}

// ── 1. Display All Products ────────────────────────────────
Future<void> _displayAllProducts(
  ProductService productService,
  TableView tableView,
) async {
  print('\n  Fetching products...');
  final products = await productService.getAllProducts();

  printHeader('PRODUCT LIST');
  tableView.displayProducts(products);
}

// ── 2. View Product Details ────────────────────────────────
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

// ── 3. Search Products ─────────────────────────────────────
Future<void> _searchProducts(
  ProductService productService,
  TableView tableView,
) async {
  final keyword = readString(prompt: '  Search keyword: ');
  final products = await productService.searchProducts(keyword: keyword);

  printHeader('SEARCH RESULTS — "$keyword"');
  tableView.displayProducts(products);
}

// ── 4. Add New Product ─────────────────────────────────────
Future<void> _addProduct(
  ProductService productService,
  TableView tableView,
) async {
  printHeader('ADD NEW PRODUCT');

  await _viewAllCategories(productService, tableView);

  final categoryId = readInt(prompt: '\n  Category ID  : ', min: 1);
  final productName = readString(prompt: '  Product Name : ');
  final price = readDouble(prompt: '  Price \$      : ', min: 0.01);
  final stock = readInt(prompt: '  Stock Qty    : ', min: 0);

  printHeader('CONFIRM NEW PRODUCT');
  tableView.printTable(
    ['Field', 'Value'],
    [
      ['Name', productName],
      ['Price', '\$${price.toStringAsFixed(2)}'],
      ['Stock', stock.toString()],
    ],
    numericColumns: [false, false],
  );

  final confirm = readYesNo(prompt: '  Save product?');
  if (!confirm) {
    print('  Cancelled.');
    return;
  }

  await productService.createProduct(
    productName: productName,
    price: price,
    stock: stock,
    categoryId: categoryId,
  );
  print('  ✅ Product "$productName" added successfully!');
}

// ── 5. Update Product ──────────────────────────────────────
Future<void> _updateProduct(
  ProductService productService,
  TableView tableView,
) async {
  final id = readInt(prompt: '  Enter Product ID to update: ', min: 1);
  final p = await productService.getProductById(id: id);

  printHeader('UPDATE PRODUCT — ${p.name}');

  // Show current values
  tableView.printTable(
    ['Field', 'Current Value'],
    [
      ['ID', p.id.toString()],
      ['Name', p.name],
      ['Category', p.categoryName ?? ''],
      ['Price', '\$${p.price?.toStringAsFixed(2)}'],
      ['Stock', p.stock.toString()],
    ],
    numericColumns: [false, false],
  );

  // Show categories
  await _viewAllCategories(productService, tableView);

  final categoryId = readInt(
    prompt: '\n  New Category ID [${p.categoryId}] : ',
    min: 1,
  );
  final productName = readString(prompt: '  New Name        [${p.name}] : ');
  final price = readDouble(prompt: '  New Price       [${p.price}] \$ : ', min: 0.01);
  final stock = readInt(prompt: '  New Stock       [${p.stock}] : ', min: 0);

  printHeader('CONFIRM UPDATE');
  tableView.printTable(
    ['Field', 'New Value'],
    [
      ['Name', productName],
      ['Price', '\$${price.toStringAsFixed(2)}'],
      ['Stock', stock.toString()],
    ],
    numericColumns: [false, false],
  );

  final confirm = readYesNo(prompt: '  Confirm update?');
  if (!confirm) {
    print('  Cancelled.');
    return;
  }

  await productService.updateProduct(
    id: id,
    productName: productName,
    price: price,
    stock: stock,
    categoryId: categoryId,
  );
  print('  ✅ Product updated successfully!');
}

// ── 6. Delete Product ──────────────────────────────────────
Future<void> _deleteProduct(
  ProductService productService,
  TableView tableView,
) async {
  final id = readInt(prompt: '  Enter Product ID to delete: ', min: 1);
  final p = await productService.getProductById(id: id);

  printHeader('DELETE PRODUCT');
  tableView.printTable(
    ['Field', 'Value'],
    [
      ['ID', p.id.toString()],
      ['Name', p.name],
      ['Price', '\$${p.price?.toStringAsFixed(2)}'],
      ['Stock', p.stock.toString()],
    ],
    numericColumns: [false, false],
  );

  final confirm = readYesNo(prompt: '  Confirm delete?');
  if (!confirm) {
    print('  Cancelled.');
    return;
  }

  await productService.deleteProduct(id: id);
  print('  ✅ Product "${p.name}" deleted successfully!');
}

// ── 7. Manage Stock ────────────────────────────────────────
Future<void> _manageStock(
  ProductService productService,
  TableView tableView,
) async {
  printHeader('MANAGE STOCK');
  await _displayAllProducts(productService, tableView);

  final id = readInt(prompt: '\n  Enter Product ID : ', min: 1);
  final p = await productService.getProductById(id: id);

  print('\n  Product       : ${p.name}');
  print('  Current Stock : ${p.stock}');

  final newStock = readInt(prompt: '  New Stock Qty  : ', min: 0);
  final confirm = readYesNo(prompt: '  Confirm stock update?');
  if (!confirm) {
    print('  Cancelled.');
    return;
  }

  await productService.manageStock(
    id: p.id!,
    productName: p.name,
    price: p.price ?? 0,
    newStock: newStock,
    categoryId: p.categoryId ?? 1,
  );
  print('  ✅ Stock updated to $newStock successfully!');
}

// ── 8. View All Categories ─────────────────────────────────
Future<void> _viewAllCategories(
  ProductService productService,
  TableView tableView,
) async {
  final categories = await productService.getAllCategories();

  printHeader('CATEGORIES');
  tableView.displayCategories(categories);
}

// ── 9. View All Orders ─────────────────────────────────────
Future<void> _viewAllOrders(
  ProductService productService,
  TableView tableView,
) async {
  final orders = await productService.getAllOrders();

  printHeader('ALL ORDERS');
  tableView.displayOrders(orders);
}

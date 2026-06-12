import 'package:pos_frontend/models/product.dart';

class CartItem {
  Product product;
  int quantity; // mutable — quantity can be updated

  // Parameterized constructor
  CartItem({required this.product, required this.quantity});

  // Calculated subtotal for this line item
  double get subtotal => (product.price ?? 0) * quantity;

}

class OrderItem {
  String? productName;
  int? quantity;
  double? price;
  double? subtotal;

  OrderItem({this.productName, this.quantity, this.price, this.subtotal});
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productName: json['product_name'],
      quantity: json['quantity'],
      price: json['price'],
      subtotal: json['subtotal']?.toDouble(),
    );
  }
}

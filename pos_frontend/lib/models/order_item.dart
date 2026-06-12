class OrderItem {
  int? id;
  int? orderId;
  int? productId;
  String? productName;
  int? quantity;
  double? unitPrice;
  double? subtotal;

  OrderItem({
    this.id,
    this.orderId,
    this.productId,
    this.productName,
    this.quantity,
    this.unitPrice,
    this.subtotal,
  });

  // Factory constructor — converts JSON from API response
  OrderItem.fromJson(Map<String, dynamic> json) {
    id = int.parse((json['id'] ?? '0').toString());
    orderId = int.parse((json['order_id'] ?? '0').toString());
    productId = int.parse((json['product_id'] ?? '0').toString());
    productName = (json['product_name'] ?? 'Unknow Item').toString();
    quantity = int.parse((json['quantity'] ?? '0').toString());
    unitPrice = double.parse((json['unit_price'] ?? '0').toString());
    subtotal = double.parse((json['subtotal'] ?? '0').toString());
  }
}

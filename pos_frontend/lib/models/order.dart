import 'package:pos_frontend/models/order_item.dart';

class Order {
  int? id;
  int? userId;
  String? userName;
  double? total;
  String? createdAt;

  List<OrderItem>? items;
  Order({
    this.id, 
    this.userId, 
    this.userName, 
    this.total, 
    this.createdAt, 
    this.items = const [],});
}

factory Order.fromJson(Map<String, dynamic> json) {
  return Order(
    id: json['id'],
    userId: json['user_id'],
    userName: json['user_name'],
    total: json['total'].toDouble(),
    createdAt: json['created_at'],
    items: (json['items'] as List)
        .map((item) => OrderItem.fromJson(item))
        .toList(),
  );
}

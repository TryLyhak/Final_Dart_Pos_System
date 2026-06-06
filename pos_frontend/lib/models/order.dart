import 'package:pos_frontend/models/order_item.dart';

class Order {
  int? id;
  int? userId;
  String? userName;
  double? total;
  String? status;
  String? createdAt;

  List<OrderItem>? items;
  Order({
    this.id,
    this.userId,
    this.userName,
    this.total,
    this.status,
    this.createdAt,
    this.items = const [],
  });

  // Factory constructor — converts JSON from API response
  Order.fromJson(Map<String, dynamic> json) {
    id = int.parse((json['id'] ?? '0').toString());
    userId = int.parse((json['user_id'] ?? '0').toString());
    userName = (json['user_name'] ?? '').toString();
    total = double.parse((json['total'] ?? '0').toString());
    status = (json['status'] ?? '').toString();
    createdAt = (json['created_at'] ?? '').toString();

    // ✅ Parse nested order items if present — receipt view
    final rawItems = json['items'] as List<dynamic>? ?? [];
    items = rawItems
        .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}

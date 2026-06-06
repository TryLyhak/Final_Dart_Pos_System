class Product {
  int? id;
  int? categoryId;
  String? categoryName;
  String? productName;
  double? price;
  int? stock;

  Product({
    this.id,
    this.categoryId,
    this.categoryName,
    this.productName,
    this.price,
    this.stock,
  });

  // Factory constructor — converts JSON from API response
  Product.fromJson(Map<String, dynamic> json) {
    id = int.parse((json['id'] ?? '0').toString());
    productName = (json['product_name'] ?? '').toString();
    price = double.parse((json['price'] ?? '0').toString());
    stock = int.parse((json['stock'] ?? '0').toString());
    categoryId = int.parse((json['category_id'] ?? '0').toString());
    categoryName = (json['category_name'] ?? '').toString();
  }

  String get name => productName ?? '';
}

class Product {
  int? id;
  int? categoryId;
  String? categoryName;
  String? productName;
  double? price;
  int? stock;

  Product({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.productName,
    required this.price,
    required this.stock,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      categoryId: json['category_id'],
      categoryName: json['category_name'],
      productName: json['product_name'],
      price: double.parse(json['price'].toString()),
      stock: json['stock'],
    );
  }

  void printRow() {
    print(
      '[${id.toString().padRight(3)}] '
      '[${productName?.padRight(20)}]'
      '\$${price?.toStringAsFixed(2).padLeft(8)}'
      'Stock: $stock',
    );
  }
}

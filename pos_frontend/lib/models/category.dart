class Category {
  int? id;
  String? categoryName;

  Category({this.id, this.categoryName});

  Category.fromJson(Map<String, dynamic> json) {
    id = int.parse((json['id'] ?? '0').toString());
    categoryName = (json['category_name'] ?? '').toString();
  }
  String get name => categoryName ?? '';
  @override
  String toString() => '[$id] $categoryName';
}

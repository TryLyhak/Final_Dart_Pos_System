class User {
  int? id;
  String? userName;
  String? role;

  User({required this.id, required this.userName, required this.role});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(id: json['id'], userName: json['name'], role: json['role']);
  }
  bool get isAdmin => role?.toLowerCase() == 'admin';
}

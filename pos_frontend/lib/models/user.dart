import 'package:pos_frontend/enum/user_role.dart';

class User {
  int? id;
  String? username;
  UserRole? role;

  // Parameterized constructor
  User({this.id, this.username, this.role});

  // Factory constructor — converts JSON from login response
  User.fromJson(Map<String, dynamic> json) {
    id = int.parse((json['id'] ?? '0').toString());
    username = (json['username'] ?? '').toString();
    role = json['role'] == 'admin' ? UserRole.admin : UserRole.sale;
  }

  // Check role using enum
  bool get isAdmin => role == UserRole.admin;
  bool get isSale => role == UserRole.sale;

  // Display name
  String get name => username ?? '';
}

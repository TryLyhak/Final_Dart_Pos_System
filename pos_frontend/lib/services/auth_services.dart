import 'package:pos_frontend/enum/user_role.dart';
import 'package:pos_frontend/models/user.dart';
import 'package:pos_frontend/services/api_services.dart';
import 'package:pos_frontend/utils/exceptions.dart';

// AuthService — handles login/logout and current session

class AuthService {
  // Instance of ApiService — matches teacher's style
  final ApiService _apiService = ApiService();

  // Currently logged-in user — null if not logged in
  User? currentUser;

  // ══════════════════════════════════════════════
  // LOGIN
  // ══════════════════════════════════════════════

  Future<User> login({
    required String username,
    required String password,
  }) async {
    // ✅ Dart handles input validation
    if (username.trim().isEmpty) {
      throw ValidationException(message: 'Username is required.');
    }

    if (password.trim().isEmpty) {
      throw ValidationException(message: 'Password is required.');
    }
    try {
      final response = await _apiService.post('/login', {
        'username': username.trim(),
        'password': password.trim(),
      });

      final data = response['data'] as Map<String, dynamic>;

      // ✅ Parse user using factory constructor
      currentUser = User.fromJson(data['user'] as Map<String, dynamic>);

      return currentUser!;
    } on ApiException catch (e) {
      throw AuthException(message: e.message);
    }
  }

  // ══════════════════════════════════════════════
  // LOGOUT
  // ══════════════════════════════════════════════

  Future<void> logout() async {
    try {
      await _apiService.post('/logout', {});
    } catch (_) {
      // Always clear session even if API call fails
    } finally {
      // ✅ Clear current user
      currentUser = null;
    }
  }

  // ══════════════════════════════════════════════
  // HELPERS
  // ══════════════════════════════════════════════

  // Check if user is logged in
  bool get isLoggedIn => currentUser != null;

  // Check role using enum
  bool get isAdmin => currentUser?.role == UserRole.admin;
  bool get isSale => currentUser?.role == UserRole.sale;

  // Get current user name
  String get currentName => currentUser?.name ?? '';

  // Get current role
  UserRole? get currentRole => currentUser?.role;
}

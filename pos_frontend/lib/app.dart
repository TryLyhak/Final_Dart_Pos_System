import 'dart:io';
import 'package:pos_frontend/models/user.dart';
import 'package:pos_frontend/services/auth_services.dart';
import 'package:pos_frontend/services/product_service.dart';
import 'package:pos_frontend/utils/table_view.dart';
import 'package:pos_frontend/views/admin_menu.dart';
import 'package:pos_frontend/views/sale_menu.dart';
import 'package:pos_frontend/utils/input.dart';
import 'package:pos_frontend/utils/exceptions.dart';

// App — main application class

class App {
  // ✅ Instance based — matches teacher style
  final AuthService _authService = AuthService();
  final ProductService _productService = ProductService();
  final TableView _tableView = TableView();

  // START APP

  Future<void> startApp() async {
    // App loop — keeps running until user exits
    while (true) {
      _printWelcomeBanner();

      print('  1. Login');
      print('  0. Exit');
      print('=' * 50);

      final choice = readInt(prompt: '  Enter choice: ');

      switch (choice) {
        case 1:
          await _handleLogin();
        case 0:
          print('\n  👋 Thank you for using our POS System. Goodbye!');
          print('                 Developed By Scott!                ');
          exit(0);
        default:
          print('  ⚠ Invalid option. Please try again.');
      }
    }
  }

  // LOGIN FLOW

  Future<void> _handleLogin() async {
    printHeader('🔐 LOGIN');

    final username = readString(prompt: '  Username : ');
    final password = readString(prompt: '  Password : ');
    try {
      print('\n  Authenticating...');
      // ✅ Login — returns User object
      final User user = await _authService.login(
        username: username,
        password: password,
      );
      print('  ✅ Welcome, ${user.name}!');
      print('  Role : ${user.role.toString().split('.').last.toUpperCase()}\n');
      await Future.delayed(const Duration(milliseconds: 500));
      // ✅ Role check using enum — Dart handles!
      if (_authService.isAdmin) {
        await showAdminMenu(
          authService: _authService,
          productService: _productService,
          tableView: _tableView,
        );
      } else {
        await showSaleMenu(
          authService: _authService,
          productService: _productService,
          tableView: _tableView,
        );
      }
    } on ValidationException catch (e) {
      print('\n  ⚠ Validation: ${e.message}\n');
    } on AuthException catch (e) {
      print('\n  ❌ Login failed: ${e.message}\n');
    } on ApiException catch (e) {
      print('\n  ❌ Connection error: ${e.message}');
      print('  Make sure your PHP server is running.\n');
    } catch (e) {
      print('\n  ❌ Unexpected error: $e\n');
    }
  }

  // WELCOME BANNER
  void _printWelcomeBanner() {
    print('\n');
    print('  ╔══════════════════════════════════════════╗');
    print('  ║           POS CONSOLE SYSTEM             ║');
    print('  ║      Mobile Application I — Final        ║');
    print('  ╚══════════════════════════════════════════╝');
    print('\n');
  }
}

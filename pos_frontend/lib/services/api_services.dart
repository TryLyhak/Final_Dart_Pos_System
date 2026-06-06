import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pos_frontend/utils/exceptions.dart';

class ApiService {
  // ✅ Fixed base URL — matches your Laragon path
  final String _baseUrl = 'http://localhost/index.php';

  Map<String, String> _buildHeaders() {
    return {'Content-Type': 'application/json', 'Accept': 'application/json'};
  }

  // GET request
  Future<dynamic> get(String endpoint) async {
    try {
      final url = Uri.parse('$_baseUrl$endpoint');
      final response = await http
          .get(url, headers: _buildHeaders())
          .timeout(const Duration(seconds: 10));
      return _handleResponse(response);
    } on http.ClientException catch (e) {
      throw ApiException(
        message: 'Network error: ${e.message}',
        statusCode: 0, // ✅ fixed typo
      );
    }
  }

  // POST request
  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final url = Uri.parse('$_baseUrl$endpoint');
      final response = await http
          .post(url, headers: _buildHeaders(), body: jsonEncode(body))
          .timeout(const Duration(seconds: 10));
      return _handleResponse(response);
    } on http.ClientException catch (e) {
      throw ApiException(
        message: 'Network error: ${e.message}',
        statusCode: 0, // ✅ fixed typo
      );
    }
  }

  // ── PUT request ───────────────────────────────
  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    try {
      final url = Uri.parse('$_baseUrl$endpoint');
      final response = await http
          .put(url, headers: _buildHeaders(), body: jsonEncode(body))
          .timeout(const Duration(seconds: 10));
      return _handleResponse(response);
    } on http.ClientException catch (e) {
      throw ApiException(
        message: 'Network error: ${e.message}',
        statusCode: 0, // ✅ fixed typo
      );
    }
  }

  // ── DELETE request ────────────────────────────
  Future<dynamic> delete(String endpoint) async {
    try {
      final url = Uri.parse('$_baseUrl$endpoint');
      final response = await http
          .delete(url, headers: _buildHeaders())
          .timeout(const Duration(seconds: 10));
      return _handleResponse(response);
    } on http.ClientException catch (e) {
      throw ApiException(
        message: 'Network error: ${e.message}',
        statusCode: 0, // ✅ fixed typo
      );
    }
  }

  dynamic _handleResponse(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return body;
      }
      throw ApiException(
        message: body['message'] as String? ?? 'Unknown error',
        statusCode: response.statusCode,
      );
    } on FormatException {
      throw ApiException(
        message: 'Invalid response format from server',
        statusCode: response.statusCode,
      );
    }
  }
}

// TODO: Add flutter_secure_storage to pubspec.yaml dependencies first:
// flutter_secure_storage: ^9.0.0
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _baseUrl = 'https://meeting-stage.cib-cdc.com/api';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Login method
  static Future<bool> login(String code) async {
    try {
      // Convert string code to int (removes leading zeros)
      final cleanCode = int.parse(code);

      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'code': cleanCode, // Sends as number: 3689 instead of "003689"
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['token'] ?? data['access_token'];

        if (token != null) {
          await saveToken(token.toString());
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  // Save token securely
  static Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  // Get token securely
  static Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  // Check if token exists
  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Remove token (for logout)
  static Future<void> removeToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }

  logout() {}
}

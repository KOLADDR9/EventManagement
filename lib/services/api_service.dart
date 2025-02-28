import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:universal_html/html.dart' as html;
import '../models/event_model.dart';

class ApiService {
  static const String baseUrl = 'https://meeting-stage.cib-cdc.com/api';
  static const String apiUrl = 'https://meeting-stage.cib-cdc.com/api/meetings';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  /// Save token (handles both mobile and web storage)
  Future<void> _saveToken(String token) async {
    if (kIsWeb) {
      html.window.localStorage['auth_token'] =
          token; // Correct - using localStorage
    } else {
      await _secureStorage.write(key: 'auth_token', value: token);
    }
  }

  /// Read token (handles both mobile and web storage)
  Future<String?> _readToken() async {
    if (kIsWeb) {
      return html.window.localStorage['auth_token'];
    } else {
      return await _secureStorage.read(key: 'auth_token');
    }
  }

  /// Remove token (handles both mobile and web storage)
  Future<void> _removeToken() async {
    if (kIsWeb) {
      html.window.localStorage.remove('auth_token');
    } else {
      await _secureStorage.delete(key: 'auth_token');
    }
  }

  /// Login method
  Future<bool> login(String otp) async {
    final cleanOtp = int.parse(otp.replaceFirst(RegExp(r'^0+'), ''));
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'key': cleanOtp}),
      );

      // print('✅ Login Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['token'] ?? data['access_token'];

        if (token != null) {
          await _saveToken(token);
          return true;
        }
      }
      return false;
    } catch (e) {
      print('🚨 Login error: $e');
      return false;
    }
  }

  /// Fetch Events from API
  Future<List<Event>> fetchEvents() async {
    try {
      print('🌐 Fetching events from: $apiUrl');
      final authToken = await _readToken();
      if (authToken == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      print('✅ Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data is Map && data['status'] == true && data['result'] is List) {
          return (data['result'] as List)
              .map((json) => Event.fromJson(json))
              .toList();
        } else {
          throw Exception('Invalid API response format.');
        }
      } else if (response.statusCode == 401) {
        await _removeToken();
        throw Exception('❌ Session expired. Please login again.');
      } else {
        throw Exception('❌ Failed to load events: ${response.statusCode}');
      }
    } catch (e) {
      print('🚨 Unexpected error: $e');
      rethrow;
    }
  }

  /// Check if user has a valid token
  Future<bool> hasValidToken() async {
    try {
      final authToken = await _readToken();
      if (authToken == null) return false;

      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      throw ('🚨 Token validation error: $e');
      return false;
    }
  }

  /// Fetch User Profile
  Future<Map<String, dynamic>> fetchUserProfile() async {
    try {
      final authToken = await _readToken();
      if (authToken == null) throw Exception('No authentication token found');

      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load user profile');
      }
    } catch (e) {
      print('🚨 Error fetching user profile: $e');
      rethrow;
    }
  }
}

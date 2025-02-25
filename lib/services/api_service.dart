import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/event_model.dart';

class ApiService {
  //https://meeting-stage.cib-cdc.com/api/all-meetings
  static const String baseUrl = 'https://meeting-stage.cib-cdc.com/api';
  static const String apiUrl = 'https://meeting-stage.cib-cdc.com/api/meetings';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Add login method
  Future<bool> login(String otp) async {
    final cleanOtp = int.parse(otp.replaceFirst(RegExp(r'^0+'), ''));

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'key': cleanOtp,
        }),
      );
      print('✅ Login Response status: ${response.statusCode}');
      print('📦 Login Response data: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['token'] ?? data['access_token'];

        if (token != null) {
          // Store token in Secure Storage
          await _secureStorage.write(
              key: 'auth_token', value: token.toString());
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

      // Get token from Secure Storage
      final authToken = await _secureStorage.read(key: 'auth_token');

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

      print('✅ Response status: ${response.statusCode}');
      print('📦 Response data: ${response.body}');

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        if (data is Map && data["status"] == true && data["result"] is List) {
          return (data["result"] as List)
              .map((json) => Event.fromJson(json))
              .toList();
        } else {
          throw Exception('Invalid API response format.');
        }
      } else if (response.statusCode == 401) {
        // Clear the invalid token
        await _secureStorage.delete(key: 'auth_token');
        throw Exception('❌ Session expired. Please login again.');
      } else if (response.statusCode == 404) {
        throw Exception('❌ Error 404: API endpoint not found');
      } else {
        throw Exception('❌ Failed to load events: ${response.statusCode}');
      }
    } catch (e) {
      print('🚨 Unexpected error: $e');
      rethrow;
    }
  }

  Future<bool> hasValidToken() async {
    try {
      final authToken = await _secureStorage.read(key: 'auth_token');

      if (authToken == null) {
        return false;
      }

      // Verify token by making a test API call
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
      print('🚨 Token validation error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> fetchUserProfile() async {
    try {
      final authToken = await _secureStorage.read(key: 'auth_token');

      if (authToken == null) {
        throw Exception('No authentication token found');
      }

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

  getUserProfile() {}

  getEmployeeProfile() {}

  fetchEmployee() {}
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event_model.dart';

class ApiService {
  static const String baseUrl = 'https://meeting-stage.cib-cdc.com/api';
  static const String apiUrl = 'https://meeting-stage.cib-cdc.com/api/meetings';

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
          // Store token in SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token.toString());
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

      // Get token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

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
        if (response.statusCode == 401) {
          // Clear the invalid token
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('auth_token');

          throw Exception('❌ Session expired. Please login again.');
        }
        throw Exception('❌ Unauthorized: Check API Token');
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
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

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
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

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
}

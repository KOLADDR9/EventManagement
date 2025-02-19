import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event_model.dart';

class ApiService {
  static const String apiUrl = 'https://meeting-stage.cib-cdc.com/api/meetings';
  static const String authToken =
      'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIxIiwianRpIjoiYzE1YjZjOGNjYjdlNGNlNjdlMWVjYjZmMjA2MWQxZmQ0Yjg3NGFjYjBjZWZkOTFmZGNiZWRhMmM5ZDExMDhkNmZkZTExNzQzODAwMmNmMmIiLCJpYXQiOjE3Mzk4NjUxNjQuMjA2MzgxLCJuYmYiOjE3Mzk4NjUxNjQuMjA2Mzg1LCJleHAiOjE3NzE0MDExNjQuMTk5MzE3LCJzdWIiOiIxIiwic2NvcGVzIjpbXX0.VmMWmTswe0qdQUGtl6lTdfLVLgOeGcJ0YJB6duj-nPypBvi3n7aPHZ0SakL-Ruf2_uHEroY88m_gciAjFhFYC4CvK5huQm_PTeRJMXyuFVwycGzecjomXHW_Ja7yyZykKvuOQ33DxAZyDVv9Tmh80qj3YmeipmVtZi1Wfeta-tSI31oa0UGzFehA3NiuP-ii2TznO6dvAwnWJPphXWU4QF4rwmhqecjvNBQZzrAWA7O7VNTajohdR2V95p8ZOCwlQAitLB-Zj7HBXsLZrLp3Ru9-TfvqjD7m3maj28yDwntAw1v0oJqBPdXFh7zlr4oNxahiV8Nah8jtdv6hC7ZFlKsa0OHylvevIbtkV0uRd1sWAfE3tpoMeR2dXRB5oVf-u8iaAGHQ4mfLGO93FxzPNG3_f8M-zJz-f86SdVDCDLNq9ecplFmrr7J4DKiLBm-1duWUcmhtMLcrIQUxguQcIjIBT1_o8eenkZWbYYCSsOh2JYjD7NRVrhzUKP1_TlLFsDrMqE7U-TzirUsaJkqXUfCOAGIBVDXy25gzy_4NlZ8DRnmHJtYFlqVPUBoQT2Rf4oGHoxGTHUkQFGMywMWZTBniRKoJiliKobIcQ3RS_GiM7XCORqRoAWOgv22a4hrtjtSnaszYOdVAJE21Ti9P_N4pazxMfFM8Pw1VyDAQmJU'; // Replace with actual token

  /// Fetch Events from API
  Future<List<Event>> fetchEvents() async {
    try {
      print('🌐 Fetching events from: $apiUrl');

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
}

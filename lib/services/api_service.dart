import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event_model.dart';

class ApiService {
  static const String apiUrl = 'https://meeting-stage.cib-cdc.com/api/meetings';
  static const String authToken =
      'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIxIiwianRpIjoiN2U1ZmNhMGUwZjk5MWNiOTkwNTY4NWFhNjg2ODc4ZTg0ZjIyMjNlYjhjNjg5NjYwNGJhZWMwZDQ3NWI3ZDIxNDZmNjY1ZGUxMjU1M2U4ODYiLCJpYXQiOjE3Mzk5NTExODYuNTg1NDUxLCJuYmYiOjE3Mzk5NTExODYuNTg1NDU1LCJleHAiOjE3NzE0ODcxODYuNTc1OTMxLCJzdWIiOiIxIiwic2NvcGVzIjpbXX0.eepNHTzSjkTEAb3AahLIAlhZNIGb2xVewg7TOfE2FkHEE5g4PajvKoj8cUcLPYkFW5EIFRMiH3J7xjE3yBMfdLKg9-Dk5HzXiQZWurjsAz5d4Yy_gOjLSMyW1n8gMLCz5l4QQpOOTefSvpLoswARuzYcIb0IL-PabDrfn056BAiVa12a_uda_5vuNs29667tLAHLSXFTi3nrD3JVZr0IfguYkEzjogImIdw4Ocrd97slmJXRcqbl3wCl4N1a1-sDkL8EjPG9S8QDnTjzRhGQG1retHOBjtHPyUjS6r3yY-kyfb8c5oq9SycqL2pHBupsOHKNJrdKQ_Q7Czc8hhpoNS741nAgrrfio5m8e7EW9B2wK26UoiTN9art4oLBZvqmoxjJPGXTk6xDPnU5hTtpMdx5EY636Bn0IwgHWWoExSl3Rrco3y33plrAsintkfiwB4bMverdTkJR5C2OUHWtdFQXEosV1fQpQsGqOLBZO2Mn-INkp1iiMwf4Y3tx1y43y5ymveVjROOQeJDu5Fz8Us6HkX6vXkmKvs1pRDMqztYV3mNOO1pQmv2uIKrIGd1XO_X59RC0Lqbgs0N0dJhxbXcLvQEEt_IMSvwVybjhNsiNclOH-sWWQKCUPAPwMEocvyExCz_TU8rGjvjAWFrDa4W59sRVQldmygz9_B7eeXc'; // Replace with actual token

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

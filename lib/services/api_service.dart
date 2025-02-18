// import 'package:dio/dio.dart';
// import '../models/event_model.dart';

// class ApiService {
//   static const String apiUrl = 'http://127.0.0.1:8000/api/meetings';
//   static const String authToken =
//       'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIzIiwianRpIjoiMGU0MmNlYmVhODFhY2I4N2FmMTBjYTM0M2Q3MTQ3YmY0Yjk1NTE2YjM2NTQxZjkyOTBhMjViMzlhYzM2ZDQ3ZDAzNjc5MGYzNGJmMTRlNzkiLCJpYXQiOjE3Mzk4NTM4NjkuMDAwNTQ3LCJuYmYiOjE3Mzk4NTM4NjkuMDAwNTUxLCJleHAiOjE3NzEzODk4NjguOTg2NTAzLCJzdWIiOiIxIiwic2NvcGVzIjpbXX0.PiKhfFw7ljRSqJ77DvdTuPJ4kyHYN_aI9-gBW8rrICfHYgKiX7vezem3oCilCNLxk8lU14omZeFP9rj0myGrRhzvo1z-XH44xOpvESU17VhP6NhErugXQFhXd6-49LLUlTHnvpcwG0UxSwO2PfovQdO0nyRybOTtR-HvtsHvaJS1PYa2f44tHYn-ffOnEq2lGnycQcW3oJb5E4a22cBKmlgzGSM5qRhFAq2gC0sbheaUW0HTMTveRTUfDsVwPv5yJTSeB14DrcDfYiw927uz0TfNbhloHypZjWIEOXqcJURGPwIVyP4EYhUInTBPrHLmRI6IbGrcQcD9IxxnwgraUKKCiIMgSLKoL0AEHNSPdj0WSrWHkE7egPdczqxFNoc7_C8KCUcc4PliDqynmnYohlWYb3cbx42LwV9CmDKBARrU2womr2j9CFyp_SUzIHyoPx-2kH6mST6-NCy9AzbOvdtOptHOImMK862s556Lfk3vVEng7icsWM057pIgIL3nLNz9Jyouroqe_jPCRheGBP8OIHJSR2969H-5h1PwI2rKrgHVcb2Yg1ZqZLSJ_1LAQO9pWGGIJO1KX6dDITSK34JvD_eCiycd-cqqvxepS_bWd6DoWpN7yaygbv2IDg8mcFcfEFZGWeckPOg8pRrmUyhMhWnUMDp9_G_38z5LsEA'; // Replace with actual token

//   final Dio _dio = Dio(
//     BaseOptions(
//       baseUrl: apiUrl,
//       connectTimeout: const Duration(seconds: 10),
//       receiveTimeout: const Duration(seconds: 10),
//       headers: {
//         'Content-Type': 'application/json',
//         'Accept': 'application/json', // Ensure API returns JSON
//         'Authorization': 'Bearer $authToken',
//       },
//     ),
//   );

//   /// Fetch Events from API
//   Future<List<Event>> fetchEvents() async {
//     try {
//       print('🌐 Fetching events from: $apiUrl');

//       Response response = await _dio.get('');

//       print('✅ Response status: ${response.statusCode}');
//       print('📦 Response data: ${response.data}');

//       if (response.statusCode == 200) {
//         var data = response.data;

//         // Ensure correct JSON format
//         if (data is Map && data["status"] == true && data["result"] is List) {
//           return (data["result"] as List)
//               .map((json) => Event.fromJson(json))
//               .toList();
//         } else {
//           throw Exception('Invalid API response format.');
//         }
//       } else if (response.statusCode == 401) {
//         throw Exception('❌ Unauthorized: Check API Token');
//       } else if (response.statusCode == 404) {
//         throw Exception('❌ Error 404: API endpoint not found');
//       } else {
//         throw Exception('❌ Failed to load events: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('🚨 Unexpected error: $e');
//       rethrow; // Rethrow to propagate error
//     }
//   }
// }
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event_model.dart';

class ApiService {
  // Change to use localhost for local development
  static const String apiUrl =
      'http://127.0.0.1:8000/api/meetings'; // For Android emulator
  // static const String apiUrl = 'http://localhost:8000/api/meetings'; // For iOS simulator or your computer directly
  static const String authToken =
      'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIzIiwianRpIjoiODU2OWE4ZWNhNzkyYmVhYTdiYWVjNDhjNmZiZjYwYTA5ODkwMjljZGRhMWU4YzgwMGNhMmM4NDYwMjQ1NTg1ZTU4ZjBjNmY0ZmVjYjEyNTUiLCJpYXQiOjE3Mzk4NTQ3NjAuNzc2NjgzLCJuYmYiOjE3Mzk4NTQ3NjAuNzc2Njg3LCJleHAiOjE3NzEzOTA3NjAuNzY2NzEzLCJzdWIiOiIxIiwic2NvcGVzIjpbXX0.ereSTZT8nksmX-QYAJWxOKfL2XbaLSzsQv_POGdKhW1X-04VacwhHp7OShH8EG7zw_vaQFxVY3zWaWXYesCEfrucbX1EnYPsw-WeoN89V_3vC2W0nc3h47jI6MqNbEPRA-mLleNdS5LhaSFxLU1hbVyAwTGMTVJSE9PjxvzQ7riBKnsKs_iLT4E-J18hiyQOl0CTFMulAetahomAlE1mHA7gyAxS-KDbyQ94dVsd3TZhyTTj-C1U90RGawKOPVv6ytvA7FbGYGSvknIsQVRF9OjIrDhP5fhl4cWHakOozVtp-5YIjxPaWtpnLnq_8U75dbUuEhBS04uyO_2B8Oh6J7mjTAuTUZeZZM0kHMnR0L3CVFF5IWV7QDSJEHOJ4tU6S4NxE4FPce88I9BjY_ltKpaSy0ahXusjMjY0YdWuJn9IYyRDCOg5DYwv610iOUxzoi_pvMAAtmW8xvy2WkLKd7OPlDnhZR_o6sTHYeWeanZHq1iDXyoPSM309usjoCHP4EnEDA9JKIL4SKwm-emIY_gCCmsZ3vvebYhp1MljZG8MM_qqZyIS4-ALDoP-XVCL8WxK53CIzkghnVRwvdCNXCZaPdj8fQBVxMsWaHmOVfDqbDIS6eIIt5CgDEBrbWv0jvpKii8QzHT4lYGKt3JjsbN5X9NKDZyQm0Ry5x3AVMk'; // Replace with actual token

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

        // Ensure correct JSON format
        if (data != null &&
            data is Map &&
            data["status"] == true &&
            data["result"] is List) {
          return (data["result"] as List)
              .map((json) => Event.fromJson(json))
              .toList();
        } else {
          throw Exception('Invalid API response format or empty result.');
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
      rethrow; // Rethrow to propagate error
    }
  }
}

import 'package:event_management_app/core/config/env_config.dart';

class ApiConstants {
  static String get baseUrl => EnvConfig.baseUrl;

  // API Endpoints
  static String get loginEndpoint => '$baseUrl/login';
  static String get meetingsEndpoint => '$baseUrl/meetings';
  static String get profileEndpoint => '$baseUrl/profile';

  // Header Keys
  static const String contentType = 'Content-Type';
  static const String accept = 'Accept';
  static const String authorization = 'Authorization';

  // Header Values
  static const String applicationJson = 'application/json';

  // Storage Keys
  static const String authTokenKey = 'auth_token';
}

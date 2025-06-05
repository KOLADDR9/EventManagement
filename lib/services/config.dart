// config.dart

class Config {
  // Base URLs
  static const String apiUrlDev = 'http://127.0.0.1:8000/api';
  static const String apiUrlStaging = 'http://127.0.0.1:8000/api';
  static const String apiUrlProd = 'http://127.0.0.1:8000/api';

  // Current active URL
  static const String baseUrl = apiUrlDev;

  // API Endpoints
  static const String loginEndpoint = '$baseUrl/login';
  static const String profileEndpoint = '$baseUrl/profile';
  static const String meetingsEndpoint = '$baseUrl/meetings';
}

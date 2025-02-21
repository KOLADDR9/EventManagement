// config.dart

class Config {
  // Base URLs
  static const String apiUrlDev = 'https://meeting-stage.cib-cdc.com/api';
  static const String apiUrlStaging = 'https://meeting-stage.cib-cdc.com/api';
  static const String apiUrlProd = 'https://meeting-stage.cib-cdc.com/api';

  // Current active URL
  static const String baseUrl = apiUrlDev;

  // API Endpoints
  static const String loginEndpoint = '$baseUrl/login';
  static const String profileEndpoint = '$baseUrl/profile';
  static const String meetingsEndpoint = '$baseUrl/meetings';
}

enum Environment { staging, production }

class EnvConfig {
  static const Environment _environment = Environment.staging;

  static String get baseUrl {
    switch (_environment) {
      case Environment.staging:
        return 'https://meeting-stage.cib-cdc.com/api';
      case Environment.production:
        return 'https://meeting.cib-cdc.com/api';
    }
  }
}

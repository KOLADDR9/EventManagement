import 'package:event_management_app/core/config/base_config.dart';

class StageConfig implements BaseConfig {
  @override
  String appName = 'Event Management App';

  @override
  String baseUrl = 'https://meeting-stage.cib-cdc.com/api';

  @override
  String prefixName = 'Stage';
}

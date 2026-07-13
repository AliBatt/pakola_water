import 'package:core/core.dart';
import 'package:models/models.dart';

class AppConfig {
  const AppConfig({
    required this.appName,
    required this.requiredRole,
    required this.homeTitle,
    required this.homeSubtitle,
    required this.environment,
  });

  final String appName;
  final AppRole requiredRole;
  final String homeTitle;
  final String homeSubtitle;
  final AppEnvironment environment;
}

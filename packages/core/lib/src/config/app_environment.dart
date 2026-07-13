enum AppEnvironment {
  dev,
  staging,
  prod;

  bool get isDev => this == AppEnvironment.dev;
  bool get isProd => this == AppEnvironment.prod;

  static AppEnvironment fromString(String value) {
    return AppEnvironment.values.firstWhere(
      (env) => env.name == value,
      orElse: () => AppEnvironment.dev,
    );
  }
}

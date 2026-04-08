class AdminConfig {
  static const adminEmail = String.fromEnvironment('ADMIN_EMAIL', defaultValue: '');
  static const adminPassword = String.fromEnvironment('ADMIN_PASSWORD', defaultValue: '');
}


class ApiEnvironment {
  ApiEnvironment._();

  static const String mode = String.fromEnvironment(
    'DCX_API_MODE',
    defaultValue: 'demo',
  );

  static const String baseUrl = String.fromEnvironment(
    'DCX_API_BASE_URL',
    defaultValue: '',
  );

  static const int timeoutSeconds = int.fromEnvironment(
    'DCX_API_TIMEOUT_SECONDS',
    defaultValue: 12,
  );

  static bool get isRemoteRequested => mode.trim().toLowerCase() == 'remote';

  static bool get isRemoteConfigured => isRemoteRequested && baseUri != null;

  static bool get isDemo => !isRemoteConfigured;

  static Uri? get baseUri {
    final raw = baseUrl.trim();
    if (raw.isEmpty) return null;
    final parsed = Uri.tryParse(raw);
    if (parsed == null || !parsed.hasScheme || parsed.host.isEmpty) return null;
    return parsed;
  }

  static String get displayMode => isRemoteConfigured ? 'Remote API' : 'Local demo';

  static String get displayHost => baseUri?.host ?? 'Not configured';
}

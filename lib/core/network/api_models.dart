import 'dart:convert';

enum ApiFailureKind {
  configuration,
  timeout,
  network,
  unauthorized,
  validation,
  server,
  invalidResponse,
  unknown,
}

class ApiException implements Exception {
  final ApiFailureKind kind;
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? details;

  const ApiException({
    required this.kind,
    required this.message,
    this.statusCode,
    this.details,
  });

  @override
  String toString() => 'ApiException($kind, $statusCode, $message)';
}

class ApiResponse {
  final int statusCode;
  final Map<String, String> headers;
  final String body;

  const ApiResponse({
    required this.statusCode,
    required this.headers,
    required this.body,
  });

  bool get isSuccess => statusCode >= 200 && statusCode < 300;

  dynamic get decodedBody {
    if (body.trim().isEmpty) return null;
    return jsonDecode(body);
  }

  Map<String, dynamic> get jsonObject {
    final decoded = decodedBody;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    throw const ApiException(
      kind: ApiFailureKind.invalidResponse,
      message: 'The server returned an unexpected response format.',
    );
  }
}

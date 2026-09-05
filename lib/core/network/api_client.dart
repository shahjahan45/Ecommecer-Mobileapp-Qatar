import 'dart:convert';

import 'api_environment.dart';
import 'api_models.dart';
import 'api_transport.dart';
import 'session_controller.dart';

class ApiClient {
  final ApiTransport transport;
  final SessionController sessionController;

  ApiClient({
    ApiTransport? transport,
    SessionController? sessionController,
  })  : transport = transport ?? const DartIoApiTransport(),
        sessionController = sessionController ?? SessionController.instance;

  Future<ApiResponse> get(
    String path, {
    Map<String, String>? queryParameters,
    bool authenticated = true,
  }) =>
      _send(
        'GET',
        path,
        queryParameters: queryParameters,
        authenticated: authenticated,
      );

  Future<ApiResponse> post(
    String path, {
    Object? body,
    String? idempotencyKey,
    bool authenticated = true,
  }) =>
      _send(
        'POST',
        path,
        body: body,
        idempotencyKey: idempotencyKey,
        authenticated: authenticated,
      );

  Future<ApiResponse> patch(
    String path, {
    Object? body,
    String? idempotencyKey,
  }) =>
      _send('PATCH', path, body: body, idempotencyKey: idempotencyKey);

  Future<ApiResponse> delete(
    String path, {
    Object? body,
    bool authenticated = true,
  }) =>
      _send('DELETE', path, body: body, authenticated: authenticated);

  Future<ApiResponse> _send(
    String method,
    String path, {
    Object? body,
    String? idempotencyKey,
    bool authenticated = true,
    Map<String, String>? queryParameters,
  }) async {
    final base = ApiEnvironment.baseUri;
    if (!ApiEnvironment.isRemoteConfigured || base == null) {
      throw const ApiException(
        kind: ApiFailureKind.configuration,
        message: 'Remote API mode is not configured for this build.',
      );
    }

    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    final basePath = base.path.endsWith('/') ? base.path : '${base.path}/';
    final uri = base.replace(
      path: '$basePath$normalizedPath',
      queryParameters: queryParameters == null || queryParameters.isEmpty
          ? null
          : queryParameters,
    );

    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json; charset=utf-8',
      'X-DCX-App': 'mobile',
      'X-DCX-Client-Version': '1.19.4',
    };

    if (authenticated) {
      final token = sessionController.bearerToken;
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    if (idempotencyKey != null && idempotencyKey.isNotEmpty) {
      headers['Idempotency-Key'] = idempotencyKey;
    }

    final maxAttempts = method == 'GET' || idempotencyKey != null ? 2 : 1;
    ApiResponse? response;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        response = await transport.send(
          method: method,
          uri: uri,
          headers: headers,
          body: body == null ? null : jsonEncode(body),
          timeout: Duration(seconds: ApiEnvironment.timeoutSeconds),
        );
        break;
      } on ApiException catch (error) {
        final retryable = error.kind == ApiFailureKind.network ||
            error.kind == ApiFailureKind.timeout;
        if (!retryable || attempt == maxAttempts) rethrow;
        await Future<void>.delayed(Duration(milliseconds: 220 * attempt));
      }
    }

    final resolvedResponse = response;
    if (resolvedResponse == null) {
      throw const ApiException(
        kind: ApiFailureKind.unknown,
        message: 'The request could not be completed.',
      );
    }

    if (resolvedResponse.isSuccess) return resolvedResponse;

    if (resolvedResponse.statusCode == 401) {
      sessionController.expire();
      throw ApiException(
        kind: ApiFailureKind.unauthorized,
        statusCode: resolvedResponse.statusCode,
        message: 'Your session has expired. Please sign in again.',
      );
    }

    Map<String, dynamic>? details;
    String? serverMessage;
    try {
      final decoded = resolvedResponse.decodedBody;
      if (decoded is Map) {
        details = Map<String, dynamic>.from(decoded);
        serverMessage = details['message'] as String?;
      }
    } catch (_) {
      // Preserve the friendly fallback below when the body is not JSON.
    }

    final kind = resolvedResponse.statusCode >= 500
        ? ApiFailureKind.server
        : resolvedResponse.statusCode == 422
            ? ApiFailureKind.validation
            : ApiFailureKind.unknown;

    throw ApiException(
      kind: kind,
      statusCode: resolvedResponse.statusCode,
      details: details,
      message: serverMessage ?? 'The request could not be completed.',
    );
  }
}

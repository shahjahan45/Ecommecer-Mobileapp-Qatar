import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'api_models.dart';

abstract class ApiTransport {
  const ApiTransport();

  Future<ApiResponse> send({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    Object? body,
    required Duration timeout,
  });
}

class DartIoApiTransport extends ApiTransport {
  const DartIoApiTransport();

  @override
  Future<ApiResponse> send({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    Object? body,
    required Duration timeout,
  }) async {
    final client = HttpClient();
    client.connectionTimeout = timeout;
    try {
      final request = await client.openUrl(method, uri).timeout(timeout);
      headers.forEach(request.headers.set);
      if (body != null) {
        request.add(utf8.encode(body is String ? body : jsonEncode(body)));
      }
      final response = await request.close().timeout(timeout);
      final responseBody = await utf8.decoder.bind(response).join().timeout(timeout);
      final responseHeaders = <String, String>{};
      response.headers.forEach((name, values) {
        responseHeaders[name] = values.join(', ');
      });
      return ApiResponse(
        statusCode: response.statusCode,
        headers: responseHeaders,
        body: responseBody,
      );
    } on TimeoutException catch (_) {
      throw const ApiException(
        kind: ApiFailureKind.timeout,
        message: 'The server took too long to respond.',
      );
    } on SocketException catch (_) {
      throw const ApiException(
        kind: ApiFailureKind.network,
        message: 'The server could not be reached. Check your connection.',
      );
    } finally {
      client.close(force: true);
    }
  }
}

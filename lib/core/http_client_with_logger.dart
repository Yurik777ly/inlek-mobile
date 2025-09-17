import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:inlek/core/http_logger.dart';

class HttpClientWithLogger extends http.BaseClient {
  final http.Client _inner;
  final bool _enableLogging;

  HttpClientWithLogger({
    http.Client? inner,
    bool enableLogging = true,
  })  : _inner = inner ?? http.Client(),
        _enableLogging = enableLogging;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final startTime = DateTime.now();
    final requestId = startTime.millisecondsSinceEpoch.toString();

    if (_enableLogging) {
      HttpLogger.logRequest(request as http.Request, requestId: requestId);
    }

    try {
      final response = await _inner.send(request);
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      if (_enableLogging) {
        // Читаем тело ответа для логирования
        final responseBody = await response.stream.bytesToString();
        final loggedResponse = http.Response(
          responseBody,
          response.statusCode,
          headers: response.headers,
          request: request,
        );

        HttpLogger.logResponse(loggedResponse,
            requestId: requestId, duration: duration);

        // Возвращаем новый StreamedResponse с тем же телом
        return http.StreamedResponse(
          Stream.value(utf8.encode(responseBody)),
          response.statusCode,
          headers: response.headers,
          request: request,
        );
      }

      return response;
    } catch (e) {
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      if (_enableLogging) {
        HttpLogger.logError(e, requestId: requestId, duration: duration);
      }
      rethrow;
    }
  }

  @override
  void close() {
    _inner.close();
  }
}

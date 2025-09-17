import 'dart:developer';

import 'package:http/http.dart' as http;

class HttpLogger {
  static final List<HttpLogEntry> _logs = [];
  static const int maxLogs = 1000; // Максимальное количество логов

  static void logRequest(http.Request request, {String? requestId}) {
    final entry = HttpLogEntry(
      id: requestId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      method: request.method,
      url: request.url.toString(),
      headers: request.headers,
      body: request.body,
      type: HttpLogType.request,
    );

    _addLog(entry);
    log('HTTP REQUEST: ${request.method} ${request.url}', name: 'HttpLogger');
    log('Headers: ${request.headers}', name: 'HttpLogger');
    if (request.body.isNotEmpty) {
      log('Body: ${request.body}', name: 'HttpLogger');
    }
  }

  static void logResponse(http.Response response,
      {String? requestId, Duration? duration}) {
    final entry = HttpLogEntry(
      id: requestId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      method: 'RESPONSE',
      url: response.request?.url.toString() ?? '',
      headers: response.headers,
      body: response.body,
      statusCode: response.statusCode,
      type: HttpLogType.response,
      duration: duration,
    );

    _addLog(entry);
    log('HTTP RESPONSE: ${response.statusCode} ${response.request?.url}',
        name: 'HttpLogger');
    log('Headers: ${response.headers}', name: 'HttpLogger');
    if (response.body.isNotEmpty) {
      log('Body: ${response.body}', name: 'HttpLogger');
    }
    if (duration != null) {
      log('Duration: ${duration.inMilliseconds}ms', name: 'HttpLogger');
    }
  }

  static void logError(dynamic error, {String? requestId, Duration? duration}) {
    final entry = HttpLogEntry(
      id: requestId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      method: 'ERROR',
      url: '',
      headers: {},
      body: error.toString(),
      type: HttpLogType.error,
      duration: duration,
    );

    _addLog(entry);
    log('HTTP ERROR: $error', name: 'HttpLogger');
    if (duration != null) {
      log('Duration: ${duration.inMilliseconds}ms', name: 'HttpLogger');
    }
  }

  static void _addLog(HttpLogEntry entry) {
    _logs.insert(0, entry); // Добавляем в начало списка

    // Ограничиваем количество логов
    if (_logs.length > maxLogs) {
      _logs.removeRange(maxLogs, _logs.length);
    }
  }

  static List<HttpLogEntry> getLogs() {
    return List.unmodifiable(_logs);
  }

  static void clearLogs() {
    _logs.clear();
  }

  static List<HttpLogEntry> getLogsByType(HttpLogType type) {
    return _logs.where((log) => log.type == type).toList();
  }

  static List<HttpLogEntry> searchLogs(String query) {
    final lowerQuery = query.toLowerCase();
    return _logs.where((log) {
      return log.url.toLowerCase().contains(lowerQuery) ||
          log.method.toLowerCase().contains(lowerQuery) ||
          log.body.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}

class HttpLogEntry {
  final String id;
  final DateTime timestamp;
  final String method;
  final String url;
  final Map<String, String> headers;
  final String body;
  final int? statusCode;
  final HttpLogType type;
  final Duration? duration;

  HttpLogEntry({
    required this.id,
    required this.timestamp,
    required this.method,
    required this.url,
    required this.headers,
    required this.body,
    this.statusCode,
    required this.type,
    this.duration,
  });

  String get formattedTimestamp {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}.'
        '${timestamp.millisecond.toString().padLeft(3, '0')}';
  }

  String get formattedDuration {
    if (duration == null) return 'N/A';

    if (duration!.inMilliseconds < 1000) {
      return '${duration!.inMilliseconds}ms';
    } else if (duration!.inSeconds < 60) {
      return '${(duration!.inMilliseconds / 1000).toStringAsFixed(1)}s';
    } else {
      final minutes = duration!.inMinutes;
      final seconds = duration!.inSeconds % 60;
      return '${minutes}m ${seconds}s';
    }
  }

  String get shortUrl {
    final uri = Uri.tryParse(url);
    if (uri == null) return url;
    return '${uri.host}${uri.path}';
  }

  bool get isSuccess {
    if (statusCode == null) return false;
    return statusCode! >= 200 && statusCode! < 300;
  }

  bool get isError {
    if (statusCode == null) return type == HttpLogType.error;
    return statusCode! >= 400;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'method': method,
      'url': url,
      'headers': headers,
      'body': body,
      'statusCode': statusCode,
      'type': type.toString(),
      'duration': duration?.inMilliseconds,
    };
  }

  factory HttpLogEntry.fromJson(Map<String, dynamic> json) {
    return HttpLogEntry(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      method: json['method'],
      url: json['url'],
      headers: Map<String, String>.from(json['headers']),
      body: json['body'],
      statusCode: json['statusCode'],
      type: HttpLogType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => HttpLogType.request,
      ),
      duration: json['duration'] != null
          ? Duration(milliseconds: json['duration'])
          : null,
    );
  }
}

enum HttpLogType {
  request,
  response,
  error,
}

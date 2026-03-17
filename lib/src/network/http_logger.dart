import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Logging verbosity level.
enum LogLevel {
  none, // no logs
  basic, // curl only (URL + method)
  headers, // curl + headers
  body, // full curl (body/query included)
}

class HttpLogger {
  /// Current logging level.
  static LogLevel logLevel = kDebugMode ? LogLevel.body : LogLevel.none;

  /// Whether logging is enabled by default.
  static bool defaultEnableLogging = kDebugMode;

  static void setLogLevel(LogLevel level) {
    logLevel = level;
  }

  static void setDefaultEnableLogging(bool enable) {
    defaultEnableLogging = enable;
  }

  static bool shouldLog(Map<String, dynamic>? extra) {
    if (extra != null && extra.containsKey('enableLogging')) {
      return extra['enableLogging'] == true;
    }
    return defaultEnableLogging;
  }

  /// When true, also print a single-line curl for easy copy-paste to terminal.
  static bool curlSingleLineCopy = true;

  /// Logs request as a copyable curl command.
  static void logRequest(
    String url,
    String method,
    Map<String, dynamic>? headers,
    dynamic body,
    Map<String, dynamic>? extra,
  ) {
    if (logLevel == LogLevel.none || !shouldLog(extra)) return;

    final curlLines = _buildCurlLines(url, method, headers, body);
    debugPrint('══════════════════════ cURL ══════════════════════════');
    for (final line in curlLines) {
      debugPrint(line);
    }
    if (curlSingleLineCopy) {
      final oneLine = _buildCurlSingleLine(url, method, headers, body);
      if (oneLine != null && oneLine.isNotEmpty) {
        debugPrint('────────────────── copy as one line ──────────────────');
        debugPrint(oneLine);
      }
    }
    debugPrint('════════════════════════════════════════════════════════');
  }

  /// Builds a multi-line curl command for readability and terminal copy/paste
  /// (line continuation with trailing `\`).
  static List<String> _buildCurlLines(
    String url,
    String method,
    Map<String, dynamic>? headers,
    dynamic body,
  ) {
    final methodUpper = method.toUpperCase();
    final isGet = methodUpper == 'GET';

    // For GET, append map body as query parameters in URL.
    String fullUrl = url;
    String? dataPiece;
    if (body != null && body is Map<String, dynamic> && body.isNotEmpty) {
      if (isGet) {
        final query = body.entries
            .map((e) =>
                '${Uri.encodeComponent(e.key.toString())}=${Uri.encodeComponent(e.value?.toString() ?? '')}')
            .join('&');
        fullUrl = url.contains('?') ? '$url&$query' : '$url?$query';
      } else {
        final jsonStr = jsonEncode(body);
        dataPiece = _escapeSingleQuotes(jsonStr);
      }
    } else if (body != null && body is String && body.isNotEmpty && !isGet) {
      dataPiece = _escapeSingleQuotes(body);
    }

    final lines = <String>[];
    lines.add('curl \\');
    lines.add('  -X $methodUpper \\');
    lines.add('  ${_escapeUrl(fullUrl)} \\');

    if (logLevel == LogLevel.headers || logLevel == LogLevel.body) {
      if (headers != null && headers.isNotEmpty) {
        for (final e in headers.entries) {
          final v = e.value?.toString() ?? '';
          lines.add("  -H ${_escapeHeader('${e.key}: $v')} \\");
        }
      }
    }
    if ((logLevel == LogLevel.body) && dataPiece != null) {
      lines.add('  -d \'$dataPiece\'');
    }

    // Do not keep line-continuation on the last line.
    if (lines.isNotEmpty && lines.last.endsWith(' \\')) {
      lines[lines.length - 1] = lines.last.substring(0, lines.last.length - 2);
    }
    return lines;
  }

  /// Builds curl as a single line for easy copy-paste.
  static String? _buildCurlSingleLine(
    String url,
    String method,
    Map<String, dynamic>? headers,
    dynamic body,
  ) {
    final lines = _buildCurlLines(url, method, headers, body);
    if (lines.isEmpty) return null;
    return lines
        .map((s) => s.endsWith(' \\') ? s.substring(0, s.length - 2) : s)
        .join(' ');
  }

  static String _escapeUrl(String s) {
    return "'${_escapeSingleQuotes(s)}'";
  }

  static String _escapeHeader(String s) {
    return "'${_escapeSingleQuotes(s)}'";
  }

  static String _escapeSingleQuotes(String s) {
    return s.replaceAll("'", r"'\''");
  }

  /// Logs response (status code, latency, optional body).
  static void logResponse(
    String url,
    int statusCode,
    Map<String, dynamic>? headers,
    dynamic body,
    int? timeInMillis,
    Map<String, dynamic>? extra,
  ) {
    if (logLevel == LogLevel.none || !shouldLog(extra)) return;

    final timeStr = timeInMillis != null ? ' ${timeInMillis}ms' : '';
    debugPrint('══════════════════════ RESPONSE ══════════════════════════');
    debugPrint('$statusCode$timeStr  $url');
    if (logLevel == LogLevel.body && body != null) {
      debugPrint('BODY:');
      _printFormatted(body, prefix: '  ');
    }
    debugPrint('════════════════════════════════════════════════════════');
  }

  /// Logs request error.
  static void logError(
    String url,
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extra,
  ) {
    if (logLevel == LogLevel.none || !shouldLog(extra)) return;

    debugPrint('══════════════════════ HTTP ERROR ═════════════════════════');
    debugPrint('URL: $url');
    debugPrint('ERROR: $error');
    if (logLevel == LogLevel.body && stackTrace != null) {
      debugPrint('STACK TRACE:');
      for (final line in stackTrace.toString().split('\n')) {
        debugPrint('  $line');
      }
    }
    debugPrint('════════════════════════════════════════════════════════');
  }

  static void _printFormatted(dynamic data, {String prefix = ''}) {
    try {
      String formattedData;
      if (data is String) {
        try {
          formattedData = const JsonEncoder.withIndent('  ')
              .convert(json.decode(data) as Object);
        } catch (_) {
          formattedData = data;
        }
      } else if (data is Map || data is List) {
        formattedData = const JsonEncoder.withIndent('  ').convert(data);
      } else {
        formattedData = data.toString();
      }
      for (final line in formattedData.split('\n')) {
        debugPrint('$prefix$line');
      }
    } catch (_) {
      debugPrint('$prefix[Unformattable]: $data');
    }
  }
}

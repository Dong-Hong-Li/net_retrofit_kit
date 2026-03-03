import 'dart:convert';
import 'package:flutter/foundation.dart';

/// 日志等级
enum LogLevel {
  none, // 不输出日志
  basic, // 只输出 curl（仅 URL、方法）
  headers, // curl + 请求头
  body, // 完整 curl（含 body/query）
}

class HttpLogger {
  /// 当前日志等级
  static LogLevel logLevel = kDebugMode ? LogLevel.body : LogLevel.none;

  /// 是否默认开启日志
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

  /// 记录请求：输出可复制的 curl 命令
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
    debugPrint('════════════════════════════════════════════════════════');
  }

  /// 构建多行 curl 命令，便于阅读和复制到终端执行（每行末尾 `\` 续行）
  static List<String> _buildCurlLines(
    String url,
    String method,
    Map<String, dynamic>? headers,
    dynamic body,
  ) {
    final methodUpper = method.toUpperCase();
    final isGet = methodUpper == 'GET';

    // URL：GET 时把 body 当作 query 拼到 URL
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

    // 最后一行不要续行符
    if (lines.isNotEmpty && lines.last.endsWith(' \\')) {
      lines[lines.length - 1] = lines.last.substring(0, lines.last.length - 2);
    }
    return lines;
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

  /// 记录响应（状态码、耗时、可选 body）
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

  /// 记录错误
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
      debugPrint('$prefix[不可格式化]: $data');
    }
  }
}

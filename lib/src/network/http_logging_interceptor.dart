import 'package:dio/dio.dart';
import 'package:net_retrofit_kit/src/network/http_logger.dart';

/// 默认日志拦截器：根据 [Options.extra]['enableLogging'] 决定是否输出请求/响应/错误。
/// 在 [NetRequest.createDio] 或设置 [NetRequest.options] 时会自动挂到 Dio 实例上。
class HttpLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final headers = options.headers.map((k, v) => MapEntry(k, v.toString()));
    HttpLogger.logRequest(
      options.uri.toString(),
      options.method,
      headers,
      options.data,
      options.extra,
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final extra = response.requestOptions.extra;
    final map = extra;
    final startTime = map['startTime'];
    final timeInMillis = startTime is int
        ? DateTime.now().millisecondsSinceEpoch - startTime
        : null;
    final headersMap = response.headers.map.entries
        .map((e) => MapEntry(e.key, e.value.join(', ')));
    HttpLogger.logResponse(
      response.requestOptions.uri.toString(),
      response.statusCode ?? 0,
      Map.fromEntries(headersMap),
      response.data,
      timeInMillis,
      map,
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    HttpLogger.logError(
      err.requestOptions.uri.toString(),
      err,
      err.stackTrace,
      err.requestOptions.extra,
    );
    handler.next(err);
  }
}

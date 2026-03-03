import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:net_retrofit_kit/src/network/net_content_type.dart';
import 'package:net_retrofit_kit/src/network/default/default_net_client.dart';
import 'package:net_retrofit_kit/src/network/http_constant.dart';
import 'package:net_retrofit_kit/src/network/http_logging_interceptor.dart';
import 'package:net_retrofit_kit/src/network/http_method.dart';
import 'package:net_retrofit_kit/src/network/inet_client.dart';
import 'package:net_retrofit_kit/src/network/net_options.dart';

class NetRequest {
  static Dio? _dio;
  static final Map<String, INetClient> _clients = {};

  /// 默认 Client 的 key，未传 [clientKey] 时使用。
  static const String defaultClientKey = 'default';

  /// 注入默认 [INetClient] 实现，等价于 [setClient]([defaultClientKey], client)。单测时可替换为 Mock。
  static set client(INetClient? c) {
    setClient(defaultClientKey, c);
  }

  /// 按名称注册或移除 [INetClient]。同一进程内可按场景区分，例如：业务 API、上传、SSE 等用不同 key。
  /// - [name]：区分不同 client，如 `'default'`、`'upload'`、`'sse'`；建议用常量或枚举值。
  /// - [client]：为 null 时移除该 name 的注册。
  static void setClient(String name, INetClient? client) {
    if (client == null) {
      _clients.remove(name);
    } else {
      _clients[name] = client;
    }
  }

  /// 获取已注册的 [INetClient]。[name] 为空时使用 [defaultClientKey]。
  static INetClient? getClient([String? name]) =>
      _clients[name ?? defaultClientKey];

  static NetOptions? _options;

  static NetOptions get options {
    if (_options != null) {
      return _options!;
    }
    throw StateError('请先设置 NetRequest.options 或 NetRequest.dioInstance 再发起请求。');
  }

  /// 根据 [NetOptions] 创建 Dio 实例（默认日志拦截器 + [NetOptions.interceptors]）。
  /// 业务方也可在创建后追加拦截器再通过 [use] 注入，或运行时用 [addInterceptor]。
  static Dio createDio(NetOptions options) {
    final dio = Dio(
      BaseOptions(
        connectTimeout: options.connectTimeout,
        receiveTimeout: options.receiveTimeout,
        sendTimeout: options.sendTimeout,
        baseUrl: options.baseUrl,
      ),
    );
    dio.interceptors.add(HttpLoggingInterceptor());
    for (final interceptor in options.interceptors ?? <Interceptor>[]) {
      dio.interceptors.add(interceptor);
    }
    return dio;
  }

  /// 向当前 Dio 实例追加一个拦截器（与 Dio 的 [Interceptor] 一致）。
  /// 需在 [options] 或 [use] 之后调用，否则抛 [StateError]。
  static void addInterceptor(Interceptor interceptor) {
    _dioInstance.interceptors.add(interceptor);
  }

  /// 向当前 Dio 实例按序追加多个拦截器。
  static void addInterceptors(List<Interceptor> interceptors) {
    _dioInstance.interceptors.addAll(interceptors);
  }

  /// 注入已配置好的 Dio 实例（如通过 [createDio] 创建并追加拦截器后）。
  /// 测试时可注入 Mock Dio。
  @visibleForTesting
  static void use(Dio dio) {
    _dio = dio;
  }

  /// 测试用：直接设置 Dio 实例，等同于 [use]。便于单测注入 Mock。
  @visibleForTesting
  static set dioInstance(Dio dio) {
    _dio = dio;
  }

  /// 注入配置，必须在发起任何请求前调用（通常放在 main 或 App 启动处）。
  /// 内部会调用 [createDio] 并覆盖当前 _dio，若需先配置再追加拦截器，请使用 [createDio] + [use]。
  static set options(NetOptions options) {
    _options = options;
    _dio = createDio(options);
  }

  static Dio get _dioInstance {
    final dio = _dio;
    if (dio == null) {
      throw StateError(
          '请先设置 NetRequest.options 或 NetRequest.dioInstance 再发起请求。');
    }
    return dio;
  }

  static DefaultNetClient _defaultClient() => DefaultNetClient(_dioInstance);

  /// 底层 Dio 实例，用于流式请求（SSE、Stream）等需自行维护的场景。
  ///
  /// 流式请求不通过 [requestHttp]，可选用 [requestStreamResponse] 或直接使用 [dio] 发起。
  static Dio get dio => _dioInstance;

  /// 流式响应入口：与 [requestHttp] 参数一致，但返回原始 [Response]（[response.data] 为 [ResponseBody]，含 [ResponseBody.stream]）。
  ///
  /// 供生成器生成「返回 Stream 的方法」：先 await [requestStreamResponse]，再返回 `response.data?.stream`；
  /// 若为 SSE，可用 [SseStreamParser.parse](response.data!.stream) 得到 `Stream<String>`。
  /// 调用方负责：消费 stream、[cancelToken] 取消、异常与关闭。
  static Future<Response> requestStreamResponse({
    required String url,
    required HttpMethod method,
    Map<String, dynamic>? queryParameters,
    dynamic body,
    ContentType contentType = ContentType.json,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    bool enableLogging = false,
    CancelToken? cancelToken,
  }) async {
    final dio = _dioInstance;
    final options = Options(
      responseType: ResponseType.stream,
      contentType: contentType.toStringType(),
      headers: headers,
      extra: {
        'startTime': DateTime.now().millisecondsSinceEpoch,
        'enableLogging': enableLogging,
        ...?extra,
      },
    );
    final q = queryParameters ?? <String, dynamic>{};
    switch (method) {
      case HttpMethod.get:
        return dio.get(url,
            queryParameters: q.isNotEmpty ? q : null,
            options: options,
            cancelToken: cancelToken);
      case HttpMethod.post:
        return dio.post(url,
            data: body,
            queryParameters: q.isNotEmpty ? q : null,
            options: options,
            cancelToken: cancelToken);
      case HttpMethod.put:
        return dio.put(url,
            data: body,
            queryParameters: q.isNotEmpty ? q : null,
            options: options,
            cancelToken: cancelToken);
      case HttpMethod.delete:
        return dio.delete(url,
            data: body,
            queryParameters: q.isNotEmpty ? q : null,
            options: options,
            cancelToken: cancelToken);
    }
  }

  /// 通用请求入口（设计对齐 Retrofit：Query 用 [queryParameters]，Body 用 [body]）。
  /// 成功约定：HTTP 2xx 且 response.code == [BusinessCode.success] 时返回 [BaseResponse]；否则抛 [ApiError]。
  /// [clientKey] 指定具名 client，为空则用 [defaultClientKey]；未注册时走包内默认实现。
  /// [cancelToken] 可选，页面 dispose 时取消可避免「页面已关仍回调」。
  static Future<BaseResponse<T>> requestHttp<T>({
    required String url,
    required HttpMethod method,
    Map<String, dynamic>? queryParameters,
    dynamic body,
    ContentType contentType = ContentType.json,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    bool enableLogging = false,
    String? clientKey,
    CancelToken? cancelToken,
    DataParser<T>? parser,
  }) async {
    final client = getClient(clientKey);
    if (client != null) {
      return client.requestHttp<T>(
        url: url,
        method: method,
        queryParameters: queryParameters,
        body: body,
        contentType: contentType,
        headers: headers,
        extra: extra,
        enableLogging: enableLogging,
        cancelToken: cancelToken,
        parser: parser,
      );
    }
    return _defaultClient().requestHttp<T>(
      url: url,
      method: method,
      queryParameters: queryParameters,
      body: body,
      contentType: contentType,
      headers: headers,
      extra: extra,
      enableLogging: enableLogging,
      cancelToken: cancelToken,
      parser: parser,
    );
  }
}

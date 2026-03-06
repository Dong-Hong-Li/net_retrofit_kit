import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:net_retrofit_kit/src/network/net_content_type.dart';
import 'package:net_retrofit_kit/src/network/http_constant.dart';
import 'package:net_retrofit_kit/src/network/http_logging_interceptor.dart';
import 'package:net_retrofit_kit/src/network/http_method.dart';
import 'package:net_retrofit_kit/src/network/inet_client.dart';
import 'package:net_retrofit_kit/src/network/istream_net_client.dart';
import 'package:net_retrofit_kit/src/network/net_options.dart';

class NetRequest {
  static Dio? _dio;
  static final Map<String, INetClient> _clients = {};
  static final Map<String, IStreamNetClient> _streamClients = {};

  /// Constant key for the default client, commonly used as initial [defaultKey].
  static const String defaultClientKey = 'default';

  /// Default client name used when [clientKey] is not provided.
  /// Example: `NetRequest.defaultKey = 'upload'`.
  /// Rule: if no clientKey is provided and exactly one client is registered,
  /// use that one; otherwise use [defaultKey].
  static String defaultKey = defaultClientKey;

  /// Injects [INetClient] under [defaultClientKey], equivalent to
  /// [setClient]([defaultClientKey], client). Useful for test-time mocking.
  static set client(INetClient? c) {
    setClient(defaultClientKey, c);
  }

  /// Registers or removes [INetClient] by name.
  /// Different keys can be used for different scenarios in the same process
  /// (e.g. business API, upload, SSE).
  /// - [name]: client key such as `'default'`, `'upload'`, `'sse'`.
  /// - [client]: if null, remove registration for [name].
  static void setClient(String name, INetClient? client) {
    if (client == null) {
      _clients.remove(name);
    } else {
      _clients[name] = client;
    }
  }

  /// Resolves key used when clientKey is not explicitly provided:
  /// if one client is registered use that key, otherwise use [defaultKey].
  static String? _resolveClientKey(String? key) {
    if (key != null && key.isNotEmpty) return key;
    if (_clients.isEmpty) return null;
    if (_clients.length == 1) return _clients.keys.single;
    return defaultKey;
  }

  /// Returns registered [INetClient].
  /// If [name] is empty, it is resolved with [defaultKey] rules.
  static INetClient? getClient([String? name]) {
    final k = _resolveClientKey(name);
    return k != null ? _clients[k] : null;
  }

  /// Registers or removes [IStreamNetClient] by name.
  /// Kept separate from [setClient] so regular clients are not mixed with
  /// streaming capabilities.
  static void setStreamClient(String name, IStreamNetClient? client) {
    if (client == null) {
      _streamClients.remove(name);
    } else {
      _streamClients[name] = client;
    }
  }

  /// Resolves key used when stream clientKey is not explicitly provided:
  /// if one stream client is registered use that key, otherwise use [defaultKey].
  static String? _resolveStreamClientKey(String? key) {
    if (key != null && key.isNotEmpty) return key;
    if (_streamClients.isEmpty) return null;
    if (_streamClients.length == 1) return _streamClients.keys.single;
    return defaultKey;
  }

  /// Returns registered [IStreamNetClient].
  /// If [name] is empty, it is resolved with [defaultKey] rules.
  static IStreamNetClient? getStreamClient([String? name]) {
    final k = _resolveStreamClientKey(name);
    return k != null ? _streamClients[k] : null;
  }

  static NetOptions? _options;

  static NetOptions get options {
    if (_options != null) {
      return _options!;
    }
    throw StateError(
      'Set NetRequest.options or NetRequest.dioInstance before sending requests.',
    );
  }

  /// Creates a Dio instance from [NetOptions]
  /// (default logging interceptor + [NetOptions.interceptors]).
  /// You can add extra interceptors after creation and inject via [use],
  /// or append at runtime via [addInterceptor].
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

  /// Appends one interceptor to current Dio instance.
  /// Call after [options] or [use], otherwise throws [StateError].
  static void addInterceptor(Interceptor interceptor) {
    _dioInstance.interceptors.add(interceptor);
  }

  /// Appends multiple interceptors to current Dio instance in order.
  static void addInterceptors(List<Interceptor> interceptors) {
    _dioInstance.interceptors.addAll(interceptors);
  }

  /// Injects a preconfigured Dio instance
  /// (for example created by [createDio] and extended with interceptors).
  /// Useful for tests.
  @visibleForTesting
  static void use(Dio dio) {
    _dio = dio;
  }

  /// Test helper: directly sets Dio instance, same behavior as [use].
  @visibleForTesting
  static set dioInstance(Dio dio) {
    _dio = dio;
  }

  /// Injects options and must be called before any request
  /// (typically in main/app startup).
  /// Internally calls [createDio] and replaces current _dio.
  /// If you need to add interceptors after create, use [createDio] + [use].
  static set options(NetOptions options) {
    _options = options;
    _dio = createDio(options);
  }

  static Dio get _dioInstance {
    final dio = _dio;
    if (dio == null) {
      throw StateError(
        'Set NetRequest.options or NetRequest.dioInstance before sending requests.',
      );
    }
    return dio;
  }

  /// Underlying Dio instance used as fallback for streaming requests
  /// (SSE/Stream and similar).
  ///
  /// Streaming requests do not go through [requestHttp].
  /// Use [requestStreamResponse] or [dio] directly.
  static Dio get dio => _dioInstance;

  /// Streaming response entry point.
  /// Parameters are aligned with [requestHttp], but it returns raw [Response]
  /// (`response.data` is [ResponseBody] containing [ResponseBody.stream]).
  ///
  /// For generated methods returning Stream:
  /// await [requestStreamResponse] first, then return `response.data?.stream`.
  /// For SSE, you may parse via
  /// [SseStreamParser.parse](response.data!.stream) to get `Stream<String>`.
  /// Caller is responsible for consumption, [cancelToken], errors, and closing.
  ///
  /// - [clientKey] optional: resolves registered stream client by [defaultKey]
  ///   rules.
  /// - If no matching stream client is found, falls back to [dio].
  static Future<Response> requestStreamResponse({
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
  }) async {
    final resolvedKey = _resolveStreamClientKey(clientKey);
    if (resolvedKey != null) {
      final streamClient = _streamClients[resolvedKey];
      if (streamClient == null) {
        throw StateError(
          'Stream client not registered: "$resolvedKey". '
          'Call NetRequest.setStreamClient("$resolvedKey", yourClient) first.',
        );
      }
      return streamClient.requestStreamResponse(
        url: url,
        method: method,
        queryParameters: queryParameters,
        body: body,
        contentType: contentType,
        headers: headers,
        extra: extra,
        enableLogging: enableLogging,
        cancelToken: cancelToken,
      );
    }
    return _requestStreamWithDio(
      url: url,
      method: method,
      queryParameters: queryParameters,
      body: body,
      contentType: contentType,
      headers: headers,
      extra: extra,
      enableLogging: enableLogging,
      cancelToken: cancelToken,
    );
  }

  /// Default streaming request implementation using Dio.
  static Future<Response> _requestStreamWithDio({
    required String url,
    required HttpMethod method,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? body,
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

  /// Generic request entry point aligned with Retrofit semantics:
  /// Query uses [queryParameters], body uses [body].
  ///
  /// Success contract:
  /// HTTP 2xx and response.code == [BusinessCode.success] returns [BaseResponse];
  /// otherwise [ApiError] is thrown.
  ///
  /// [clientKey] optional:
  /// when omitted, if exactly one client is registered that one is used;
  /// otherwise [defaultKey] is used. Missing registration throws [StateError].
  ///
  /// [cancelToken] optional:
  /// cancelling during widget dispose can avoid callbacks after page close.
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
    final resolvedKey = _resolveClientKey(clientKey);
    final client = resolvedKey != null ? _clients[resolvedKey] : null;
    if (client == null) {
      throw StateError(
        resolvedKey == null
            ? 'No client registered. Call NetRequest.setClient(name, yourClient) first.'
            : 'Client not registered: "$resolvedKey". '
                'Call NetRequest.setClient("$resolvedKey", yourClient) first.',
      );
    }
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
}

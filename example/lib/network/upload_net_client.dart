// 自定义 Client 示例：实现 [INetClient]，上传请求走独立逻辑（如专用 baseUrl、超时、自定义请求头等）。

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:net_retrofit_kit/net_retrofit_kit.dart';

/// 示例：自定义上传用 Client，实现 [INetClient] 并注册为 `upload`。
/// 与默认 Client 区分：可单独配置 baseUrl/超时、加自定义 Header、重试、统计等。
class UploadNetClient implements INetClient {
  UploadNetClient(this._dio);

  final Dio _dio;

  static const String _clientHeader = 'X-Client';

  @override
  Future<BaseResponse<T>> requestHttp<T>({
    required String url,
    required HttpMethod method,
    Map<String, dynamic>? queryParameters,
    dynamic body,
    ContentType contentType = ContentType.json,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    bool enableLogging = false,
    CancelToken? cancelToken,
    DataParser<T>? parser,
  }) async {
    final mergedHeaders = <String, dynamic>{
      _clientHeader: 'upload', // 自定义：标识请求来自 upload Client
      ...?headers,
    };
    try {
      final options = Options(
        contentType: contentType.toStringType(),
        headers: mergedHeaders,
        extra: {
          'startTime': DateTime.now().millisecondsSinceEpoch,
          'enableLogging': enableLogging,
          ...?extra,
        },
      );
      final response = await _sendRequest(
        method.string,
        url,
        queryParameters ?? <String, dynamic>{},
        body,
        options,
        contentType: contentType,
        cancelToken: cancelToken,
      );
      _ensureSuccessStatus(response);
      return _handleResponseJson<T>(response, parser: parser);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  void _ensureSuccessStatus(Response response) {
    final code = response.statusCode ?? 0;
    if (code < 200 || code >= 300) {
      throw ApiError(
        kind: ApiErrorKind.networkFailure,
        message: 'HTTP $code',
        data: response.data,
      );
    }
  }

  Future<Response> _sendRequest(
    String method,
    String url,
    Map<String, dynamic> queryParams,
    dynamic body,
    Options options, {
    required ContentType contentType,
    CancelToken? cancelToken,
  }) async {
    dynamic data = body;
    if (contentType == ContentType.formData) {
      if (data is FormData) {
        // 已构建 FormData，直接使用
      } else if (data is Map<String, dynamic>) {
        data = FormData.fromMap(data);
      }
    }
    switch (method.toUpperCase()) {
      case 'GET':
        return _dio.get(
          url,
          queryParameters: queryParams.isNotEmpty ? queryParams : null,
          options: options,
          cancelToken: cancelToken,
        );
      case 'POST':
        return _dio.post(
          url,
          data: data,
          queryParameters: queryParams.isNotEmpty ? queryParams : null,
          options: options,
          cancelToken: cancelToken,
        );
      case 'PUT':
        return _dio.put(
          url,
          data: data,
          queryParameters: queryParams.isNotEmpty ? queryParams : null,
          options: options,
          cancelToken: cancelToken,
        );
      case 'DELETE':
        return _dio.delete(
          url,
          data: data,
          queryParameters: queryParams.isNotEmpty ? queryParams : null,
          options: options,
          cancelToken: cancelToken,
        );
      default:
        throw UnsupportedError('不支持的请求方法: $method');
    }
  }

  BaseResponse<T> _handleResponseJson<T>(
    Response response, {
    DataParser<T>? parser,
  }) {
    final resData = response.data is String
        ? jsonDecode(response.data as String) as dynamic
        : response.data;
    final json =
        resData is Map<String, dynamic> ? resData : <String, dynamic>{};
    // 自定义：无 code 的响应（如 httpbin）视为成功，用整份 body 作为 data
    if (!json.containsKey('code')) {
      final data = parser != null ? parser(json) : json as T;
      return BaseResponse<T>(code: 0, msg: 'ok', data: data);
    }
    final base = BaseResponse<T>.fromJson(
      json,
      dataParser: parser != null ? (raw) => parser(raw) : null,
    );
    if (!base.isSuccess) {
      throw ApiError.businessReject(
        code: base.code,
        message: base.msg,
        data: base.data,
      );
    }
    return base;
  }
}

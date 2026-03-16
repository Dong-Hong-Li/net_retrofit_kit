// ignore_for_file: deprecated_member_use

// Custom Client example: implements [INetClient] so upload requests use separate logic (e.g. dedicated baseUrl, timeout, custom headers).

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:net_retrofit_kit/net_retrofit_kit.dart';

/// Example: custom upload Client implementing [INetClient], registered as `upload`.
/// Separate from default client: can configure baseUrl/timeout, custom headers, retry, metrics, etc.
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
      _clientHeader: 'upload', // Custom: marks request as from upload Client
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
      throw ApiError.fromDioError(e);
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
        // FormData already built, use as-is
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
        throw UnsupportedError('Unsupported request method: $method');
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
    // Custom: responses without 'code' (e.g. httpbin) treated as success; use full body as data
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

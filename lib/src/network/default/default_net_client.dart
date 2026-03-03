import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:net_retrofit_kit/src/network/net_content_type.dart';
import 'package:net_retrofit_kit/src/network/http_constant.dart';
import 'package:net_retrofit_kit/src/network/http_error.dart';
import 'package:net_retrofit_kit/src/network/http_method.dart';
import 'package:net_retrofit_kit/src/network/inet_client.dart';

/// 基于 Dio 的默认 [INetClient] 实现，供 [NetRequest] 在未注入具名 client 时使用。
class DefaultNetClient implements INetClient {
  DefaultNetClient(this._dio);

  final Dio _dio;

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
    try {
      final options = Options(
        contentType: contentType.toStringType(),
        headers: headers,
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
        // 调用方已构建 FormData（如含 MultipartFile），直接使用
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
    final resData = _parseResponseData(response);
    final json =
        resData is Map<String, dynamic> ? resData : <String, dynamic>{};
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

  dynamic _parseResponseData(Response response) {
    final data = response.data;
    return data is String ? jsonDecode(data) : data;
  }
}

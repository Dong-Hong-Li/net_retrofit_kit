import 'package:dio/dio.dart';
import 'package:net_retrofit_kit/src/network/http_constant.dart';
import 'package:net_retrofit_kit/src/network/http_method.dart';
import 'package:net_retrofit_kit/src/network/net_content_type.dart';

/// Regular HTTP client abstraction for easier mocking and replacement.
///
/// Designed to align with Retrofit semantics:
/// Query goes into [queryParameters], body goes into [body], and annotation
/// mapping is handled by the caller (generator).
///
/// Streaming requests (SSE/Stream) are handled by a separate
/// `IStreamNetClient` abstraction.
abstract class INetClient {
  /// Generic HTTP request.
  ///
  /// - [url] request URL (without query string).
  /// - [method] HTTP method.
  /// - [queryParameters] query params appended to URL, for Retrofit
  ///   @Query / @QueryMap.
  /// - [body] request payload for POST/PUT/etc., for Retrofit @Body.
  ///   Supported values: [Map], class model with [toJson] (generator emits
  ///   body.toJson()), or [FormData]/Map for [ContentType.formData]
  ///   (file fields use [MultipartFile]).
  /// - [contentType] request Content-Type.
  /// - [headers] / [extra] request headers and extension metadata.
  /// - [enableLogging] whether to enable logging for this request.
  /// - [cancelToken] cancellation token.
  /// - [parser] parses the business payload inside the JSON envelope into T
  ///   (see [BaseResponse.data]).
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
  });
}

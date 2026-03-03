import 'package:dio/dio.dart';
import 'package:net_retrofit_kit/src/network/net_content_type.dart';
import 'package:net_retrofit_kit/src/network/http_constant.dart';
import 'package:net_retrofit_kit/src/network/http_method.dart';

/// 普通 HTTP 客户端抽象，便于单测注入 Mock 或替换实现。
///
/// 设计对齐 Retrofit：Query 用 [queryParameters]，Body 用 [body]，由调用方（生成器）按注解区分。
///
/// 流式请求（SSE、Stream）不在此接口内，使用独立的 `IStreamNetClient` 抽象。
abstract class INetClient {
  /// 通用 HTTP 请求。
  ///
  /// - [url] 请求 URL（不含 query 部分）。
  /// - [method] 请求方法。
  /// - [queryParameters] Query 参数（拼到 URL），对应 Retrofit @Query / @QueryMap。
  /// - [body] 请求体（POST/PUT 等），对应 Retrofit @Body。可为 Map、可 toJson 的对象、或 [ContentType.formData] 时的 [FormData]/Map（文件字段用 [MultipartFile]）。
  /// - [contentType] 请求 Content-Type。
  /// - [headers] / [extra] 请求头与扩展数据。
  /// - [enableLogging] 是否在本请求中启用日志。
  /// - [cancelToken] 取消令牌。
  /// - [parser] 将 response.data 解析为 T。
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

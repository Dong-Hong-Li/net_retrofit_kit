import 'package:dio/dio.dart';
import 'package:net_retrofit_kit/src/network/http_method.dart';
import 'package:net_retrofit_kit/src/network/net_content_type.dart';

/// 流式网络客户端抽象（SSE/Stream）。
///
/// 与 [INetClient] 分离，避免普通 HTTP Client 被迫实现流式能力。
abstract class IStreamNetClient {
  /// 发起流式请求，返回原始 [Response]（`response.data` 一般为 [ResponseBody]）。
  Future<Response> requestStreamResponse({
    required String url,
    required HttpMethod method,
    Map<String, dynamic>? queryParameters,
    dynamic body,
    ContentType contentType = ContentType.json,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    bool enableLogging = false,
    CancelToken? cancelToken,
  });
}

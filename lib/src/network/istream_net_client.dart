import 'package:dio/dio.dart';
import 'package:net_retrofit_kit/src/network/http_method.dart';
import 'package:net_retrofit_kit/src/network/net_content_type.dart';

/// Streaming network client abstraction (SSE/Stream).
///
/// Separated from [INetClient] so regular HTTP clients are not forced to
/// implement streaming capabilities.
/// [body] follows the same contract as [INetClient]: pass `Map` directly;
/// class models are converted with `toJson()` by generated code.
abstract class IStreamNetClient {
  /// Sends a streaming request and returns the raw [Response]
  /// (`response.data` is typically [ResponseBody]).
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

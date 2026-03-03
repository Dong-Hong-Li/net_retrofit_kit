// 与 lib/src/network [INetClient.requestHttp] 契约一致，生成代码调用 NetRequest.requestHttp / client.requestHttp。
//
// 参数对应：url=baseUrl+path, method, queryParameters, body, headers, contentType, clientKey, parser 均由注解/返回类型生成；
// cancelToken：若方法有可选参数 CancelToken? cancelToken，生成器透传；extra / enableLogging 无注解，生成器可不传或默认。

import 'package:net_retrofit_kit/src/network/net_content_type.dart';

// ========================== 类级 ==========================

/// 标在抽象类上，声明 Retrofit 风格 API 接口。
///
/// 生成器为该类生成实现类，并调用 [NetRequest.requestHttp]（或 [INetClient.requestHttp]）。
/// 参数对应关系：
/// - [client] → requestHttp 的 [clientKey]，为 null 时用 [NetRequest.defaultClientKey]
/// - [responseType] → 解析时使用的响应类型名（如 BaseResponse）
/// - [unwrapSuccess] → 成功时返回 response.data（true）还是整份 response（false）
class NetApi {
  const NetApi({
    this.client,
    this.responseType = 'BaseResponse',
    this.unwrapSuccess = true,
  });

  /// 对应 [NetRequest.requestHttp] 的 [clientKey]，null 表示 default
  final String? client;

  /// 统一响应类型名
  final String responseType;

  /// 成功时只返回 data（true）还是整份 response（false）
  final bool unwrapSuccess;
}

/// **与注解对应关系**（见 `lib/src/generate/annotations.dart`）：
/// | 本接口参数 | 注解 / 约定 |
/// |------------|-------------|
/// | [url] | @Get/@Post/@Put/@Delete 的 path，与 baseUrl 拼接 |
/// | [method] | @Get → get, @Post → post, @Put → put, @Delete → delete |
/// | [queryParameters] | @Query() 参数整体 或 @QueryKey(name) 合并 |
/// | [body] | @Body() 参数（toJson 或 Map） |
/// | [contentType] | @Get(..., contentType: ...) 等，默认 json |
/// | [headers] | @Header(name) 参数合并 |
/// | [extra] | 无注解，生成器可不传 |
/// | [enableLogging] | 无注解，生成器默认 false |
/// | [cancelToken] | 方法可选参数 CancelToken? cancelToken 透传 |
/// | [parser] | 返回类型 + @DataPath 生成 DataParser |
/// | formData / 文件上传 | [contentType]=formData，[body] 为 FormData 或 Map（文件值用 MultipartFile）；注解可用 @Part(name) 多参拼 FormData |

/// ========================== 方法级：HTTP 方法 + 路径 ==========================

/// HTTP 方法注解基类，生成器据此取 [path] 拼 [url]、选 [HttpMethod]。
abstract class HttpMethodAnnotation {
  const HttpMethodAnnotation(
    this.path, {
    this.contentType,
  });

  /// 相对路径，与 baseUrl 拼接得到 [NetRequest.requestHttp] 的 [url]
  final String path;

  /// 对应 [NetRequest.requestHttp] 的 [contentType]，null 表示默认 ContentType.json
  final ContentType? contentType;
}

/// GET 请求 → method: HttpMethod.get, url: baseUrl + path
class Get extends HttpMethodAnnotation {
  const Get(super.path, {super.contentType});
}

/// POST 请求 → method: HttpMethod.post, body 对应 requestHttp 的 [body]
class Post extends HttpMethodAnnotation {
  const Post(super.path, {super.contentType});
}

/// PUT 请求
class Put extends HttpMethodAnnotation {
  const Put(super.path, {super.contentType});
}

/// DELETE 请求
class Delete extends HttpMethodAnnotation {
  const Delete(super.path, {super.contentType});
}

// ========================== 方法级：响应解析 ==========================

/// 从 response.data[path] 解析模型，而非 response.data。
///
/// 生成器构造 [DataParser] 时使用 `response.data?[path]` 再传入 T.fromJson。
class DataPath {
  const DataPath(this.path);
  final String path;
}

/// 后端返回流（SSE/Stream）时使用：生成器应调用 [NetRequest.requestStreamResponse]，再按返回类型或约定返回 stream。
///
/// 生成器根据方法返回类型决定实现，例如：
/// - 返回 `Future<Stream<String>>`：可用 [SseStreamParser.parse](response.data!.stream)（SSE）或 utf8.decoder + LineSplitter（按行）；
/// - 返回 `Future<Stream<List<int>>>`：直接返回 response.data?.stream。
/// 生成器需将 [cancelToken] 等可选参数透传 [requestStreamResponse]，由调用方负责消费与取消。
///
/// ```dart
/// @Get('/stream')
/// @StreamResponse()
/// Future<Stream<String>> getStream({CancelToken? cancelToken});
/// ```
class StreamResponse {
  const StreamResponse();
}

// ========================== 参数级：请求体与 Query（对应 requestHttp 的 body / queryParameters） ==========================

/// 该参数作为请求体 → requestHttp 的 [body]（生成代码传 param.toJson() 或 param）
class Body {
  const Body();
}

/// 用于 multipart/form-data 的一个字段/文件
///
/// 与 [ContentType.formData] 配合：方法上使用 @Post(path, contentType: ContentType.formData)，
/// 多个 [Part] 参数由生成器拼成 [FormData] 作为 [body]；若参数类型为 File，生成器应转为
/// [MultipartFile] 再填入 FormData。也可不用 [Part]，直接传 [body] 为 Map 或 FormData。
///
/// ```dart
/// @Post('/upload', contentType: ContentType.formData)
/// Future<Result?> upload(@Part('file') File file, @Part('name') String name);
///
/// ```
class Part {
  const Part(this.name);
  final String name;
}

/// 该参数作为 Query 整体 → requestHttp 的 [queryParameters]
///
/// ```dart
/// @Get('/user')
/// Future<UserModel?> getUser(@Query() Map<String, dynamic> query);
///
/// request:
/// ?id=1&name=user1
/// ```
class Query {
  const Query();
}

/// 单参数对应 query 的一个 key → 合并到 requestHttp 的 [queryParameters][name]
///
/// ```dart
/// @Get('/user')
/// Future<UserModel?> getUser(@QueryKey('id') int id);
///
/// request:
/// ?id=1&name=user1
/// ```
class QueryKey {
  const QueryKey(this.name);
  final String name;
}

// ========================== 参数级：可选扩展 ==========================

/// 该参数作为请求头的一个 key → requestHttp 的 [headers][name]
///
/// ```dart
/// @Get('/user')
/// Future<UserModel?> getUser(@Header('Authorization') String token);
/// ```
class Header {
  const Header(this.name);
  final String name;
}

/// Path 占位符：方法 path 中 {name} 由该参数替换，如 @Get('/user/{id') + @Path('id') int id
///
/// ```dart
/// @Get('/user/{id}')
/// Future<UserModel?> getUser(@Path('id') int id);
/// ```
class Path {
  const Path(this.name);
  final String name;
}

// Aligned with the contract of lib/src/network [INetClient.requestHttp].
// Generated code calls NetRequest.requestHttp / client.requestHttp.
//
// Parameter mapping:
// url=baseUrl+path, method, queryParameters, body, headers, contentType,
// clientKey, and parser are generated from annotations and return type.
// cancelToken is forwarded when a method defines optional
// CancelToken? cancelToken; extra/enableLogging have no annotations.

import 'package:net_retrofit_kit/src/network/net_content_type.dart';

// ========================== Class-level ==========================

/// Applied to abstract classes to declare a Retrofit-style API interface.
///
/// The generator creates an implementation and calls [NetRequest.requestHttp]
/// (or [INetClient.requestHttp]).
/// Parameter mapping:
/// - [client] -> requestHttp [clientKey]. If omitted, [NetRequest.defaultKey]
///   rules are used (single registered client -> use it, otherwise defaultKey).
/// - [responseType] -> response wrapper type name used for parsing
///   (for example `BaseResponse`).
/// - [unwrapSuccess] -> return `response.data` when true, or full response when
///   false.
class NetApi {
  const NetApi({
    this.client,
    this.responseType = 'BaseResponse',
    this.unwrapSuccess = true,
  });

  /// Maps to [NetRequest.requestHttp] [clientKey].
  /// Null means resolving by [NetRequest.defaultKey] rules.
  final String? client;

  /// Unified response wrapper type name.
  final String responseType;

  /// Return data only (true) or full response (false) on success.
  final bool unwrapSuccess;
}

/// **Annotation mapping** (see `lib/src/generate/annotations.dart`):
/// | Interface parameter | Annotation / convention |
/// |------------|-------------|
/// | [url] | path from @Get/@Post/@Put/@Delete, concatenated with baseUrl |
/// | [method] | @Get -> get, @Post -> post, @Put -> put, @Delete -> delete |
/// | [queryParameters] | full @Query() map, merged with @QueryKey(name) entries |
/// | [body] | @Body() argument (toJson or Map) |
/// | [contentType] | from annotations such as @Get(..., contentType: ...) |
/// | [headers] | merged @Header(name) arguments |
/// | [extra] | no annotation, generator may omit |
/// | [enableLogging] | no annotation, generator defaults to false |
/// | [cancelToken] | forwarded from optional CancelToken? cancelToken argument |
/// | [parser] | generated from return type + @DataPath |
/// | formData / file upload | [contentType]=formData, [body]=FormData/Map (file values use MultipartFile); @Part(name) can be merged into FormData |

/// ========================== Method-level: HTTP method + path ==========================

/// Base annotation for HTTP methods.
/// The generator uses [path] to build [url] and chooses [HttpMethod].
abstract class HttpMethodAnnotation {
  const HttpMethodAnnotation(
    this.path, {
    this.contentType,
  });

  /// Relative path. Concatenated with baseUrl to build [NetRequest.requestHttp]
  /// [url].
  final String path;

  /// Maps to [NetRequest.requestHttp] [contentType].
  /// Null means default ContentType.json.
  final ContentType? contentType;
}

/// GET request -> method: HttpMethod.get, url: baseUrl + path.
class Get extends HttpMethodAnnotation {
  const Get(super.path, {super.contentType});
}

/// POST request -> method: HttpMethod.post, body maps to requestHttp [body].
class Post extends HttpMethodAnnotation {
  const Post(super.path, {super.contentType});
}

/// PUT request.
class Put extends HttpMethodAnnotation {
  const Put(super.path, {super.contentType});
}

/// DELETE request.
class Delete extends HttpMethodAnnotation {
  const Delete(super.path, {super.contentType});
}

// ========================== Method-level: response parsing ==========================

/// Parse model from response.data[path] instead of response.data.
///
/// The generator uses `response.data?[path]` when building [DataParser] before
/// passing into T.fromJson.
class DataPath {
  const DataPath(this.path);
  final String path;
}

/// Use for streaming backend responses (SSE/Stream): the generator should call
/// [NetRequest.requestStreamResponse], then return stream based on return type
/// or convention.
///
/// Typical generation strategy:
/// - `Future<Stream<String>>`: use [SseStreamParser.parse](response.data!.stream)
///   for SSE, or utf8.decoder + LineSplitter for line-by-line parsing.
/// - `Future<Stream<List<int>>>`: return `response.data?.stream` directly.
/// Optional params like [cancelToken] should be forwarded; caller owns
/// consuming/cancelling/closing the stream lifecycle.
///
/// ```dart
/// @Get('/stream')
/// @StreamResponse()
/// Future<Stream<String>> getStream({CancelToken? cancelToken});
/// ```
class StreamResponse {
  const StreamResponse();
}

// ========================== Parameter-level: body/query ==========================

/// Marks this parameter as request body -> requestHttp [body].
///
/// Can be [Map<String, dynamic>] or any class model.
/// If type is not Map, generator emits `param.toJson()`, so models must
/// implement [toJson].
class Body {
  const Body();
}

/// Marks one multipart/form-data field or file.
///
/// Works with [ContentType.formData], for example
/// @Post(path, contentType: ContentType.formData).
/// Multiple [Part] arguments are merged into [FormData] as [body].
/// If an argument type is File, generator should convert it to
/// [MultipartFile] before inserting into FormData.
/// You can also skip [Part] and pass [body] as Map or FormData directly.
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

/// Marks this parameter as full query map -> requestHttp [queryParameters].
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

/// Maps one parameter to one query key, merged into requestHttp
/// [queryParameters][name].
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

// ========================== Parameter-level: optional extensions ==========================

/// Maps this parameter to one request header key -> requestHttp [headers][name].
///
/// ```dart
/// @Get('/user')
/// Future<UserModel?> getUser(@Header('Authorization') String token);
/// ```
class Header {
  const Header(this.name);
  final String name;
}

/// Path placeholder mapping:
/// `{name}` in method path is replaced by this argument, e.g.
/// @Get('/user/{id}') + @Path('id') int id.
///
/// ```dart
/// @Get('/user/{id}')
/// Future<UserModel?> getUser(@Path('id') int id);
/// ```
class Path {
  const Path(this.name);
  final String name;
}

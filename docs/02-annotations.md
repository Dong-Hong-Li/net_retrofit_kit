# Annotations reference

All annotations are defined in [lib/src/generate/annotations.dart](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/lib/src/generate/annotations.dart). The generator uses them to produce code that calls [NetRequest.requestHttp](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/lib/src/network/net_request.dart) (or a named [INetClient](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/lib/src/network/inet_client.dart)).

---

## Class-level: `@NetApi`

Put on the **abstract** API class.

```dart
@NetApi({
  String? client,           // clientKey for requestHttp; null = default
  String responseType = 'BaseResponse',
  bool unwrapSuccess = true,
})
abstract class MyApi { ... }
```

| Parameter | Meaning |
|-----------|--------|
| `client` | Key passed to `requestHttp(clientKey: ...)`. If set (e.g. `'upload'`), the generated code uses that client; you must register it with `NetRequest.setClient('upload', yourClient)`. |
| `responseType` | Name of the response type used when parsing (e.g. `BaseResponse`). |
| `unwrapSuccess` | If `true`, the generated code returns `response.data` on success; if `false`, the full response object. |

Example with custom client: [example/lib/server/upload_api.dart](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/example/lib/server/upload_api.dart) — `@NetApi(client: 'upload')`.

---

## Method-level: HTTP method + path

| Annotation | HTTP method | Path |
|------------|-------------|------|
| `@Get(path)` | GET | `path` (relative to baseUrl) |
| `@Post(path)` | POST | same |
| `@Put(path)` | PUT | same |
| `@Delete(path)` | DELETE | same |

Optional: `contentType` for the request body (e.g. `ContentType.formData` for uploads).

```dart
@Get('/user/list')
Future<UserList?> getList();

@Post('/user')
Future<User?> create(@Body() UserCreateRequest body);

@Post('/upload', contentType: ContentType.formData)
Future<Result?> upload(@Part('file') File file, @Part('name') String name);
```

[ContentType](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/lib/src/network/net_content_type.dart): `json`, `formData`, `xWwwFormUrlencoded`.

---

## Parameter: body and query

| Annotation | Use | Generated usage |
|------------|-----|-----------------|
| `@Body()` | Request body | `body: param` or `param.toJson()` |
| `@Query()` | Full query map | `queryParameters: param` |
| `@QueryKey(name)` | One query key | Merged into `queryParameters[name]` |

```dart
@Post('/login')
Future<Auth?> login(@Body() LoginRequest body);

@Get('/search')
Future<List<Item>?> search(@QueryKey('keyword') String q, @QueryKey('page') int page);

@Get('/list')
Future<List<Item>?> list(@Query() Map<String, dynamic> query);
```

---

## Parameter: path and header

| Annotation | Use | Path placeholder |
|------------|-----|------------------|
| `@Path(name)` | Path segment | Path must contain `:name` (e.g. `/user/:id`) |
| `@Header(name)` | One header | `headers[name]` |

```dart
@Get('/user/:id')
Future<User?> getUser(@Path('id') String id);

@Get('/resource/:type/:id')
Future<Resource?> getResource(@Path('type') String type, @Path('id') String id);

@Get('/me')
Future<User?> me(@Header('Authorization') String token);
```

---

## Response parsing

| Annotation | Use |
|------------|-----|
| `@DataPath('key')` | Parse from `response.data['key']` instead of `response.data`. |

```dart
@Get('/nested')
@DataPath('result')
Future<NestedModel?> getNested();
```

See [example/lib/server/nested_api.dart](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/example/lib/server/nested_api.dart).

---

## Multipart (file upload)

Use `@Post(path, contentType: ContentType.formData)` and `@Part(name)`:

```dart
@Post('/post', contentType: ContentType.formData)
Future<Map<String, dynamic>?> upload(
  @Part('file') File file,
  @Part('name') String name,
);
```

Generator builds `FormData` from parts; `File` is converted to `MultipartFile`. Example: [example/lib/server/upload_api.dart](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/example/lib/server/upload_api.dart).

---

## Stream / SSE

| Annotation | Use |
|------------|-----|
| `@StreamResponse()` | Method returns a stream; generator calls `NetRequest.requestStreamResponse` and returns the response stream (e.g. for SSE or line-by-line). |

```dart
@Get('/stream/3')
@StreamResponse()
Future<Stream<String>> getStreamLines({CancelToken? cancelToken});
```

Example: [example/lib/server/demo_server.dart](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/example/lib/server/demo_server.dart) — `getStreamLines`.

---

## Optional: `RequestOptions? options`

You can add an optional last parameter `RequestOptions? options` to methods. The generator passes it through (e.g. for your execute wrapper for loading/error handling). The type is from Dio.

---

## Summary table

| Annotation | Scope | Description |
|------------|--------|-------------|
| `@NetApi(...)` | Class | Client key, response type, unwrap success |
| `@Get(path)` / `@Post(path)` / `@Put(path)` / `@Delete(path)` | Method | HTTP method + path |
| `@Body()` | Parameter | Request body |
| `@Query()` | Parameter | Full query map |
| `@QueryKey(name)` | Parameter | Single query parameter |
| `@Path(name)` | Parameter | Path segment for `:name` |
| `@Header(name)` | Parameter | Request header |
| `@DataPath('key')` | Method | Parse from `data['key']` |
| `@Part(name)` | Parameter | Multipart part (formData) |
| `@StreamResponse()` | Method | Stream/SSE response |

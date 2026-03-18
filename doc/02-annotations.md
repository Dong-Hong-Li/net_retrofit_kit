# Annotations

**Quick lookup:**

| Annotation | Scope | Use |
|------------|--------|-----|
| `@NetApi(client?, responseType?, unwrapSuccess?)` | Class | Optional client; when omitted uses [NetRequest.defaultKey](04-multi-client.md#defaultkey); optional response type, return data only on success |
| `@Get(path)` `@Post(path)` `@Put(path)` `@Delete(path)` | Method | HTTP method + path; optional `contentType: ContentType.formData` |
| `@Body()` | Param | Request body |
| `@Query()` | Param | Full query map |
| `@QueryKey('name')` | Param | Single query param |
| `@Path('id')` | Param | Path segment; path has `:id` |
| `@Header('Authorization')` | Param | Request header |
| `@DataPath('key')` | Method | Parse from `response.data['key']` |
| `@Part('file')` | Param | Multipart part (use with `ContentType.formData`) |
| `@StreamResponse()` | Method | Return stream (SSE / line stream) |
| `[CallOptions? options]` (optional positional) | Method | Per-call options: cancelToken, clientKey; in `[]` to distinguish from API params in `{}`. Use `{CallOptions? options}` when method has other named params (Dart disallows `[]` + `{}` in same method) |

---

## @NetApi (class)

```dart
@NetApi()  // or @NetApi(client: 'upload', responseType: 'BaseResponse', unwrapSuccess: true)
abstract class UserApi { ... }
```

| Param | Meaning |
|-------|--------|
| `client` | Named client key; register with `NetRequest.setClient('upload', client)`. |
| `responseType` | Response type name for parsing. |
| `unwrapSuccess` | `true` → return `response.data`; `false` → full response. |

---

## HTTP method + path

```dart
@Get('/user/list')
@Post('/user', contentType: ContentType.formData)  // for upload
@Put('/user/:id')
@Delete('/user/:id')
```

Path is relative to `NetRequest.options.baseUrl`.

---

## Body, Query, Path, Header

```dart
@Post('/login')
Future<Auth?> login(@Body() LoginRequest body);

@Get('/search')
Future<List?> search(@QueryKey('keyword') String q, @QueryKey('page') int page);

@Get('/user/:id')
Future<User?> getUser(@Path('id') String id);

@Get('/me')
Future<User?> me(@Header('Authorization') String token);
```

---

## DataPath (parse from nested key)

```dart
@Get('/nested')
@DataPath('result')
Future<Nested?> getNested();
```

---

## Part (multipart / file upload)

```dart
@Post('/upload', contentType: ContentType.formData)
Future<Result?> upload(@Part('file') File file, @Part('name') String name);
```

---

## StreamResponse (stream / SSE)

```dart
@Get('/stream/3')
@StreamResponse()
Future<Stream<String>> getStreamLines({CallOptions? options});
```

---

## [CallOptions? options] (per-call options, distinct from API params)

Use **optional positional** `[CallOptions? options]` so request-level options are not confused with API params (which use named `{ }`):  
`void fn(required, [CallOptions? options], {named})`.  
When the method has other named params, Dart does not allow both `[]` and `{}` in the same method, so use `{CallOptions? options}` there.

### Generator logic

- **Detection**: optional **positional** param of type `CallOptions?`, or **named** param named `options` of type `CallOptions?`.
- **Regular/stream requests**: generates `clientKey: options?.clientKey`, `cancelToken: options?.cancelToken`. When `options` is omitted, those are null.

### Interface and example

```dart
@Get('/get')
Future<DemoModel?> getUserInfo([CallOptions? options]);

@Post('/post')
Future<DemoModel?> login(@Body() Map<String, dynamic> body, [CallOptions? options]);

@Get('/stream/3')
@StreamResponse()
Future<Stream<String>> getStreamLines([CallOptions? options]);
```

**Call site (positional):**

```dart
await api.getUserInfo();
await api.getStreamLines(CallOptions(cancelToken: token));
await api.getUserInfo(CallOptions(clientKey: 'upload'));
```

**StreamRequestPage:**  
`fetchStreamLines(CallOptions(cancelToken: _cancelToken));`

# Annotations

**Quick lookup:**

| Annotation | Scope | Use |
|------------|--------|-----|
| `@NetApi(client?, responseType?, unwrapSuccess?)` | Class | Optional client key, response type, return data only on success |
| `@Get(path)` `@Post(path)` `@Put(path)` `@Delete(path)` | Method | HTTP method + path; optional `contentType: ContentType.formData` |
| `@Body()` | Param | Request body |
| `@Query()` | Param | Full query map |
| `@QueryKey('name')` | Param | Single query param |
| `@Path('id')` | Param | Path segment; path has `:id` |
| `@Header('Authorization')` | Param | Request header |
| `@DataPath('key')` | Method | Parse from `response.data['key']` |
| `@Part('file')` | Param | Multipart part (use with `ContentType.formData`) |
| `@StreamResponse()` | Method | Return stream (SSE / line stream) |

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
Future<Stream<String>> getStreamLines({CancelToken? cancelToken});
```

---

## Optional: RequestOptions? options

Last optional param on a method: generator passes it through (e.g. for loading/error wrapper).

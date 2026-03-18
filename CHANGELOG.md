# Changelog / 更新日志

版本更新说明。格式基于 [Keep a Changelog](https://keepachangelog.com/)，版本号遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

---

## [Unreleased]

---

## [0.2.13](https://github.com/Dong-Hong-Li/net_retrofit_kit/releases/tag/v0.2.13) - 2026-03-18

### Added / 新增

**English**

- **CallOptions**: Per-call options (cancelToken, clientKey) for generated API methods. Prefer **optional positional** `[CallOptions? options]` so request-level options are distinct from API params in `{ }` (e.g. `void fn(required, [CallOptions? options], {named})`). When a method has other named params, use `{CallOptions? options}` (Dart disallows both `[]` and `{}` in the same method). Generator forwards `options?.cancelToken` and `options?.clientKey` to the request layer. Exported from `net_retrofit_kit.dart`. Documented in [Annotations](doc/02-annotations.md) / [注解说明](doc/02-注解说明.md), [CallOptions](lib/src/network/call_options.dart), and README quick reference.

**中文**

- **CallOptions**：为生成接口方法提供单次请求选项（cancelToken、clientKey）。推荐使用**可选位置参数** `[CallOptions? options]`，与 `{ }` 中的接口参数区分（如 `void fn(必填, [CallOptions? options], {可选命名})`）。若方法需其它命名参数，则用 `{CallOptions? options}`（Dart 不允许同方法同时使用 `[]` 与 `{}`）。生成器将 `options?.cancelToken`、`options?.clientKey` 透传到底层。已从 `net_retrofit_kit.dart` 导出，并在 [注解说明](doc/02-注解说明.md) / [Annotations](doc/02-annotations.md)、[CallOptions](lib/src/network/call_options.dart) 及 README 速查中说明。

---

## [0.2.12](https://github.com/Dong-Hong-Li/net_retrofit_kit/releases/tag/v0.2.12) - 2026-03-16

### Added / 新增

**English**

- **HttpLogger.curlSingleLineCopy**: When `true` (default), request logging prints a single-line curl after the multi-line one so you can copy it in one go and paste into a terminal. Set to `false` to only show the multi-line curl.
- **Docs**: [Configuration](doc/03-configuration.md) / [配置](doc/03-配置.md) now document `HttpLogger.logLevel`, `defaultEnableLogging`, and `curlSingleLineCopy`.

**中文**

- **HttpLogger.curlSingleLineCopy**：为 `true`（默认）时，请求日志在多行 curl 下方再输出一行单行 curl，便于整段复制到终端。设为 `false` 则只显示多行 curl。
- **文档**：[配置](doc/03-配置.md) / [Configuration](doc/03-configuration.md) 已补充 `HttpLogger.logLevel`、`defaultEnableLogging`、`curlSingleLineCopy` 说明。

---

## [0.2.11](https://github.com/Dong-Hong-Li/net_retrofit_kit/releases/tag/v0.2.11) - 2026-03-16

### Fixed / 修复

**English**

- **Nullable @Body()**: When the `@Body()` parameter type is nullable (e.g. `CreateWithdrawRequest? body`), the generator now emits `body?.toJson()` instead of `body.toJson()`, avoiding a null reference at runtime.

**中文**

- **可空 @Body()**：当 `@Body()` 参数为可空类型（如 `CreateWithdrawRequest? body`）时，生成器改为生成 `body?.toJson()`，不再生成 `body.toJson()`，避免运行时空引用。

---

## [0.2.8](https://github.com/Dong-Hong-Li/net_retrofit_kit/releases/tag/v0.2.8) - 2026-03-06

### Added / 新增

**English**

- **@Body() convention**: `@Body()` now accepts either `Map<String, dynamic>` or a class model. When the parameter type is not `Map`, the generator emits `param.toJson()`; the model must implement `toJson`. Documented in pubspec description, README, [INetClient]/[IStreamNetClient], and annotations.
- **Example**: Article API example extended with `createWithModel(@Body() CreateArticleRequest body)` and `updateWithModel(@Body() UpdateArticleRequest body)` plus request models `CreateArticleRequest` / `UpdateArticleRequest` with `toJson()`.

**中文**

- **@Body() 约定**：`@Body()` 现支持 `Map<String, dynamic>` 或 class model。参数类型非 Map 时，生成器生成 `param.toJson()`，模型须实现 `toJson`。已在 pubspec 描述、README、[INetClient]/[IStreamNetClient] 及注解中说明。
- **示例**：Article API 示例新增 `createWithModel(@Body() CreateArticleRequest body)`、`updateWithModel(@Body() UpdateArticleRequest body)` 及带 `toJson()` 的请求模型 `CreateArticleRequest` / `UpdateArticleRequest`。

### Changed / 变更

**English**

- **Comments and UI in English**: All comments and user-facing strings in `example/lib` (server APIs, models, network clients, examples list page) are now in English.

**中文**

- **注释与文案英文化**：`example/lib` 下所有注释及界面文案（server API、模型、网络 Client、示例列表页）已改为英文。

---

## [0.2.6](https://github.com/Dong-Hong-Li/net_retrofit_kit/releases/tag/v0.2.6) - 2026-03-05

### Changed / 变更

**English**

- **`BaseResponse<T>`**: The `data` field is now `final T data` (aligned with the generic `T`). When `data` can be null, use `BaseResponse<T?>` (e.g. `BaseResponse<int?>`). This keeps the type consistent and avoids a separate nullable field type.

**中文**

- **`BaseResponse<T>`**：`data` 字段改为 `final T data`，与泛型 `T` 一致。当 `data` 可能为 null 时，请使用 `BaseResponse<T?>`（如 `BaseResponse<int?>`），类型更一致。

---

## [0.2.5](https://github.com/Dong-Hong-Li/net_retrofit_kit/releases/tag/v0.2.5) - 2026-03-05

### Fixed / 修复

**English**

- **Code generator — return type name source**: For non-stream methods, the generator now uses the same return type name for both `requestHttp<T>` and the parser expression. That name is built from the type tree (`InterfaceType.element.name` + type arguments) in `MethodGeneratorConfig._returnTypeNameFromType`, instead of `getDisplayString()`. This avoids analyzer-inserted spaces in generics (e.g. `Response < String >`) so that both the generated generic and the parser use a consistent, parseable type (e.g. `Response<String>`).

**中文**

- **代码生成 — 返回类型名来源**：非流式方法中，生成器对 `requestHttp<T>` 与 parser 表达式统一使用同一返回类型名。该名称在 `MethodGeneratorConfig._returnTypeNameFromType` 中由类型树（`InterfaceType.element.name` + 类型实参）拼接得到，不再使用 `getDisplayString()`，避免 analyzer 在泛型中插入空格（如 `Response < String >`），保证生成的泛型与 parser 类型一致且可正确解析（如 `Response<String>`）。

### Added / 新增

**English**

- **`lib/src/generate/return_type_name.dart`**: New utility `stripReturnTypeName(display)` to extract the inner type from `Future<T>` / `Future<Stream<T>>` display strings. Handles analyzer output with spaces or a single trailing `>` so the closing `>` is not stripped incorrectly.
- **Example**: `ResponseTypeApi` in `example/lib/server/response_type_api.dart` to demonstrate generic return types (e.g. `Future<Response<String>>`) and generated parser.
- **Tests**: Unit tests for `stripReturnTypeName` (Future/Stream strip, nullable, edge cases) and a consistency check that `response_type_api.g.dart` generates `requestHttp<Response<String>>` and `Response<String>.fromJson` without spaces.

**中文**

- **`lib/src/generate/return_type_name.dart`**：新增工具函数 `stripReturnTypeName(display)`，从 `Future<T>` / `Future<Stream<T>>` 的显示字符串中提取内层类型 T；正确处理 analyzer 带空格或仅有一个闭合 `>` 的输出，避免误删泛型闭合。
- **示例**：在 `example/lib/server/response_type_api.dart` 中新增 `ResponseTypeApi`，演示泛型返回类型（如 `Future<Response<String>>`）及生成 parser。
- **测试**：为 `stripReturnTypeName` 增加单测（Future/Stream 剥离、可空、边界情况），并增加断言：`response_type_api.g.dart` 中生成 `requestHttp<Response<String>>` 与 `Response<String>.fromJson` 且无空格。

---

## [0.2.3](https://github.com/Dong-Hong-Li/net_retrofit_kit/releases/tag/v0.2.3) - 2026-03-05

### Fixed / 修复

**English**

- **Code generator**: When return type is generic (e.g. `Future<Response<String>>`), the analyzer’s `getDisplayString()` may add spaces (e.g. `Response < String >`). The generated parser was then `Response < String >.fromJson(...)`, which Dart parses as a comparison. Now generic type names are wrapped in parentheses so the output is `(Response<String>).fromJson(...)` and parses correctly.

**中文**

- **代码生成**：返回类型为泛型（如 `Future<Response<String>>`）时，analyzer 的 `getDisplayString()` 可能带空格（如 `Response < String >`），生成 `Response < String >.fromJson(...)` 会被解析成比较运算。现对泛型类型名加括号，生成 `(Response<String>).fromJson(...)`，解析正确。

### Added / 新增

- **Tests**: Added `test/generator_test.dart` for `buildParserExpression` (generic / non-generic / primitive / dataPath cases).

---

## [0.2.2](https://github.com/Dong-Hong-Li/net_retrofit_kit/releases/tag/v0.2.2) - 2026-03-03

### Added / 新增

**English**

- **`NetRequest.defaultKey`**: Assignable default client key when `clientKey` is not passed. If only one client is registered, that client is used; if multiple, `defaultKey` is used. Default value is `NetRequest.defaultClientKey` (`'default'`).
- **`IStreamNetClient`**: Added an independent stream client abstraction for SSE/stream use cases.
- **`NetRequest.setStreamClient/getStreamClient`**: Added dedicated registration and retrieval APIs for stream clients.

**中文**

- **`NetRequest.defaultKey`**：未传 `clientKey` 时使用的默认 client 名称，可指定。仅注册一个 client 时用该 client，多个时用 `defaultKey`；默认值为 `NetRequest.defaultClientKey`（`'default'`）。
- **`IStreamNetClient`**：新增独立的流式客户端抽象，用于 SSE/Stream 场景。
- **`NetRequest.setStreamClient/getStreamClient`**：新增流式客户端的独立注册与获取接口。

### Changed / 变更

**English**

- **`@NetApi(client: ...)`**: `client` is optional again; when omitted, behaviour follows `NetRequest.defaultKey` (one client → use it, multiple → use `defaultKey`).
- **`NetRequest.requestHttp(clientKey: ...)`**: `clientKey` is optional; resolution as above.
- **`NetRequest.requestStreamResponse(clientKey: ...)`**: `clientKey` is now optional and follows stream-client default-key resolution.
- **Stream routing isolation**: stream requests no longer inspect or cast `INetClient`; they only route through registered `IStreamNetClient`, with Dio fallback when no stream client is resolved.
- **Removed `lib/src/network/default/`**: Package no longer ships `DefaultNetClient`; implement `INetClient` yourself or copy from the example app `example/lib/network/default_net_client.dart`.
- **Example app**: moved default client implementation into `example/lib/network/default_net_client.dart` to keep package core maintenance scope minimal.

**中文**

- **`@NetApi(client: ...)`**：`client` 改为可选；不传时按 `NetRequest.defaultKey` 规则（一个 client 用该 client，多个用 `defaultKey`）。
- **`NetRequest.requestHttp(clientKey: ...)`**：`clientKey` 改为可选；解析规则同上。
- **`NetRequest.requestStreamResponse(clientKey: ...)`**：`clientKey` 改为可选，并按流式客户端的 defaultKey 规则解析。
- **流式路由隔离**：流式请求不再检查或强转 `INetClient`；仅通过已注册的 `IStreamNetClient` 路由，未命中时回退 Dio。
- **移除 `lib/src/network/default/`**：插件内不再维护默认 Client 实现；请自行实现 `INetClient` 或从示例工程 `example/lib/network/default_net_client.dart` 拷贝。
- **示例工程**：默认客户端实现迁移到 `example/lib/network/default_net_client.dart`，缩小插件核心维护范围。

---

## [0.1.0](https://github.com/Dong-Hong-Li/net_retrofit_kit/releases/tag/v0.1.0) - 初始发布

### Added / 新增

**English**

- **Retrofit-style API**: Abstract class with `@NetApi`, methods with `@Get` / `@Post` / `@Put` / `@Delete`, implementation generated via `build_runner`.
- **Class-level**: `@NetApi(client?, responseType?, unwrapSuccess?)` — optional client (defaultKey when omitted), optional response type, unwrap success to `data` only.
- **Method path & Content-Type**: `@Get(path)`, `@Post(path)` etc., optional `contentType: ContentType.formData`.
- **Parameter annotations**: `@Body()`, `@Query()`, `@QueryKey(name)`, `@Path(name)`, `@Header(name)`, `@DataPath('key')`, `@Part(name)`.
- **Stream**: `@StreamResponse()` — generated code calls `NetRequest.requestStreamResponse`, supports SSE/Stream.
- **Config**: `NetOptions` (baseUrl, timeouts, interceptors), set via `NetRequest.options = NetOptions(...)` at startup.
- **Response & error**: `BaseResponse<T>`, `BaseResponse.fromJson`, `ApiError` / `ApiErrorKind` (networkFailure, businessReject, cancelled).
- **Client abstraction**: `INetClient` for testing/Mock; `NetRequest.setClient(name, client)` for multiple clients (e.g. default, upload).

**中文**

- **Retrofit 风格 API**：抽象类使用 `@NetApi`，方法使用 `@Get` / `@Post` / `@Put` / `@Delete`，通过 `build_runner` 生成实现类。
- **类级注解**：`@NetApi(client?, responseType?, unwrapSuccess?)`，client 可选（不传走 defaultKey）；可选响应类型、成功时是否只返回 `data`。
- **方法级路径与 Content-Type**：`@Get(path)`、`@Post(path)` 等，支持 `contentType: ContentType.formData`。
- **参数注解**：`@Body()`、`@Query()`、`@QueryKey(name)`、`@Path(name)`、`@Header(name)`、`@DataPath('key')`、`@Part(name)`。
- **流式请求**：`@StreamResponse()`，生成代码调用 `NetRequest.requestStreamResponse`，支持 SSE/Stream。
- **配置**：`NetOptions`（baseUrl、超时、interceptors），启动时通过 `NetRequest.options = NetOptions(...)` 注入。
- **响应与错误**：`BaseResponse<T>`、`BaseResponse.fromJson`、`ApiError` / `ApiErrorKind`（networkFailure、businessReject、cancelled）。
- **Client 抽象**：`INetClient` 便于单测 Mock；`NetRequest.setClient(name, client)` 支持多 Client（如 default、upload）。

---

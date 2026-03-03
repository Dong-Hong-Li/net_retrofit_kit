# Changelog / 更新日志

版本更新说明。格式基于 [Keep a Changelog](https://keepachangelog.com/)，版本号遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

---

## [0.1.0](https://github.com/Dong-Hong-Li/net_retrofit_kit/releases/tag/v0.1.0) - 初始发布

### Added / 新增

**English**

- **Retrofit-style API**: Abstract class with `@NetApi`, methods with `@Get` / `@Post` / `@Put` / `@Delete`, implementation generated via `build_runner`.
- **Class-level**: `@NetApi(client?, responseType?, unwrapSuccess?)` — configurable client key, response type, unwrap success to `data` only.
- **Method path & Content-Type**: `@Get(path)`, `@Post(path)` etc., optional `contentType: ContentType.formData`.
- **Parameter annotations**: `@Body()`, `@Query()`, `@QueryKey(name)`, `@Path(name)`, `@Header(name)`, `@DataPath('key')`, `@Part(name)`.
- **Stream**: `@StreamResponse()` — generated code calls `NetRequest.requestStreamResponse`, supports SSE/Stream.
- **Config**: `NetOptions` (baseUrl, timeouts, interceptors), set via `NetRequest.options = NetOptions(...)` at startup.
- **Response & error**: `BaseResponse<T>`, `BaseResponse.fromJson`, `ApiError` / `ApiErrorKind` (networkFailure, businessReject, cancelled).
- **Client abstraction**: `INetClient` for testing/Mock; `NetRequest.setClient(name, client)` for multiple clients (e.g. default, upload).

**中文**

- **Retrofit 风格 API**：抽象类使用 `@NetApi`，方法使用 `@Get` / `@Post` / `@Put` / `@Delete`，通过 `build_runner` 生成实现类。
- **类级注解**：`@NetApi(client?, responseType?, unwrapSuccess?)`，可配置 Client 名称、响应类型、成功时是否只返回 `data`。
- **方法级路径与 Content-Type**：`@Get(path)`、`@Post(path)` 等，支持 `contentType: ContentType.formData`。
- **参数注解**：`@Body()`、`@Query()`、`@QueryKey(name)`、`@Path(name)`、`@Header(name)`、`@DataPath('key')`、`@Part(name)`。
- **流式请求**：`@StreamResponse()`，生成代码调用 `NetRequest.requestStreamResponse`，支持 SSE/Stream。
- **配置**：`NetOptions`（baseUrl、超时、interceptors），启动时通过 `NetRequest.options = NetOptions(...)` 注入。
- **响应与错误**：`BaseResponse<T>`、`BaseResponse.fromJson`、`ApiError` / `ApiErrorKind`（networkFailure、businessReject、cancelled）。
- **Client 抽象**：`INetClient` 便于单测 Mock；`NetRequest.setClient(name, client)` 支持多 Client（如 default、upload）。

---

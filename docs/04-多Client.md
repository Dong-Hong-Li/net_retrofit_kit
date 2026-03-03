# 多 Client

可以注册**具名** Client，并通过 `@NetApi(client: '...')` 让指定 API 使用某个 Client。每个 Client 是 [INetClient](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/lib/src/network/inet_client.dart) 的实现（例如不同 baseUrl、超时、请求头或自定义逻辑）。

---

## INetClient

接口定义：[lib/src/network/inet_client.dart](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/lib/src/network/inet_client.dart)

```dart
abstract class INetClient {
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
```

当生成代码调用 `NetRequest.requestHttp(..., clientKey: 'upload')` 时，会使用该 key 注册的 Client。若未注册，则回退到默认实现（由 `NetRequest.options` 创建的 Dio）。

---

## 注册 Client

[NetRequest](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/lib/src/network/net_request.dart)：

```dart
NetRequest.setClient(String name, INetClient? client);
```

- `name`：key，如 `'default'`、`'upload'`、`'sse'`。需与 `@NetApi(client: 'upload')` 中的字符串一致。
- `client`：你的 `INetClient` 实现。传 `null` 表示移除该 key。

可以直接使用包内的 [DefaultNetClient](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/lib/src/network/default/default_net_client.dart)，传入一个 Dio 即可：

```dart
final uploadDio = NetRequest.createDio(const NetOptions(
  baseUrl: 'https://upload.example.com',
  receiveTimeout: Duration(seconds: 120),
));
NetRequest.setClient('upload', DefaultNetClient(uploadDio));
```

---

## 自定义 Client 示例

**示例工程**里为上传实现了一个**自定义** Client（没有用 DefaultNetClient）：

- **实现类**：[example/lib/network/upload_net_client.dart](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/example/lib/network/upload_net_client.dart) — `UploadNetClient` 实现 `INetClient`。
- **行为**：使用自己的 Dio（如更长超时）、增加自定义请求头 `X-Client: upload`，并对无 `code` 字段的响应（如 httpbin）按成功处理。
- **注册**：[example/lib/main.dart](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/example/lib/main.dart) — `NetRequest.setClient('upload', UploadNetClient(uploadDio))`。
- **API**：[example/lib/server/upload_api.dart](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/example/lib/server/upload_api.dart) — `@NetApi(client: 'upload')`，该接口所有方法都走 upload Client。

该 API 的生成代码会传入 `clientKey: 'upload'`，由 `NetRequest` 转交给 `UploadNetClient` 处理。

---

## 流程小结

1. 在 `main()`（或任意请求前）：设置 `NetRequest.options`，并对每个具名 Client 调用 `NetRequest.setClient('upload', yourClient)`。
2. 在 API 类上：使用 `@NetApi(client: 'upload')`，生成器会生成 `clientKey: 'upload'`。
3. 运行时：调用该 API 的方法时，会执行 `requestHttp(..., clientKey: 'upload')`，由你注册的 Client 处理请求。

---

## 使用场景

- **上传 / CDN**：不同 baseUrl、超时。
- **SSE / 流式**：单独 Dio 或单独 Client。
- **单测**：为某个 key 注册 Mock `INetClient`。
- **鉴权**：不同 Client 使用不同拦截器或请求头。

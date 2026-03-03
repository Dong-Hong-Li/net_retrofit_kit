# 多 Client

**一句话：** 用 `NetRequest.setClient('upload', yourClient)` 注册，用 `@NetApi(client: 'upload')` 指定。

| 步骤 | 做法 |
|------|------|
| 1 | 实现 `INetClient`（或用 `DefaultNetClient(dio)`）。 |
| 2 | 在 `main()`：`NetRequest.setClient('upload', UploadNetClient(dio))`。 |
| 3 | 在 API 类上：`@NetApi(client: 'upload')`。 |

生成代码会传 `clientKey: 'upload'`，由你注册的 Client 处理请求。

---

## 注册

```dart
NetRequest.setClient(String name, INetClient? client);
```

- `name`：与 `@NetApi(client: 'upload')` 中一致。
- `client`：你的实现；传 `null` 表示移除。

---

## 使用 DefaultNetClient

```dart
final uploadDio = NetRequest.createDio(const NetOptions(
  baseUrl: 'https://upload.example.com',
  receiveTimeout: Duration(seconds: 120),
));
NetRequest.setClient('upload', DefaultNetClient(uploadDio));
```

---

## 自定义 Client

实现 `INetClient`（一个方法：`requestHttp`）。示例工程中有自定义上传 Client（独立 Dio、请求头 `X-Client: upload`）。

---

## 使用场景

- 上传 / CDN：不同 baseUrl、超时。
- SSE / 流式：独立 Dio。
- 单测：Mock `INetClient`。
- 鉴权：不同 Client 不同拦截器。

# 多 Client

**一句话：** 用 `NetRequest.setClient('upload', yourClient)` 注册，用 `@NetApi(client: 'upload')` 指定；不写 `client` 时走 [NetRequest.defaultKey](#defaultkey)。

| 步骤 | 做法 |
|------|------|
| 1 | 实现 `INetClient`（插件内不再提供默认实现，可参考示例工程 `example/lib/network/` 中的实现）。 |
| 2 | 在 `main()`：`NetRequest.setClient('upload', UploadNetClient(dio))`。 |
| 3 | 在 API 类上：`@NetApi(client: 'upload')`；不写则用 defaultKey 规则。 |

生成代码传了 `clientKey` 时用对应 Client；不传时：**只注册了一个 client 就用该 client，多个则用 `NetRequest.defaultKey`**。

---

## defaultKey

未传 `clientKey` 时（如 `@NetApi()`）：

- 若**只注册了一个** client → 使用该 client；
- 若注册了**多个** → 使用 `NetRequest.defaultKey`。

`defaultKey` 可指定，默认值为 `NetRequest.defaultClientKey`（`'default'`）：

```dart
NetRequest.defaultKey = 'default';  // 默认
NetRequest.defaultKey = 'upload';   // 多 Client 时指定默认用哪个
```

---

## 注册

```dart
NetRequest.setClient(String name, INetClient? client);
```

- `name`：与 `@NetApi(client: 'upload')` 中一致。
- `client`：你的实现；传 `null` 表示移除。

---

## 默认 Client 实现

插件内不再维护 `DefaultNetClient`，请自行实现 `INetClient` 或从示例工程 `example/lib/network/default_net_client.dart` 拷贝一份。

```dart
final uploadDio = NetRequest.createDio(const NetOptions(
  baseUrl: 'https://upload.example.com',
  receiveTimeout: Duration(seconds: 120),
));
NetRequest.setClient('upload', YourNetClient(uploadDio));  // YourNetClient 实现 INetClient
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

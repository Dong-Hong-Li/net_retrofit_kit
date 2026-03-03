# Multiple clients

**Quick:** Register with `NetRequest.setClient('upload', yourClient)`, use with `@NetApi(client: 'upload')`. When `client` is omitted, see [NetRequest.defaultKey](#defaultkey).

| Step | Do |
|------|-----|
| 1 | Implement `INetClient` (package does not ship a default implementation; see example app `example/lib/network/` for reference). |
| 2 | In `main()`: `NetRequest.setClient('upload', UploadNetClient(dio))`. |
| 3 | On API class: `@NetApi(client: 'upload')`; omit to use defaultKey rule. |

When `clientKey` is passed, that client is used. When it is not: **if only one client is registered, use it; if multiple, use `NetRequest.defaultKey`**.

---

## defaultKey

When `clientKey` is not passed (e.g. `@NetApi()`):

- If **only one** client is registered → that client is used;
- If **multiple** are registered → `NetRequest.defaultKey` is used.

`defaultKey` is assignable; default value is `NetRequest.defaultClientKey` (`'default'`):

```dart
NetRequest.defaultKey = 'default';  // default
NetRequest.defaultKey = 'upload';    // when using multiple clients, choose which is default
```

---

## Register

```dart
NetRequest.setClient(String name, INetClient? client);
```

- `name`: same as in `@NetApi(client: 'upload')`.
- `client`: your implementation; `null` to remove.

---

## Default client implementation

The package no longer maintains `DefaultNetClient`. Implement `INetClient` yourself or copy from the example app `example/lib/network/default_net_client.dart`.

```dart
final uploadDio = NetRequest.createDio(const NetOptions(
  baseUrl: 'https://upload.example.com',
  receiveTimeout: Duration(seconds: 120),
));
NetRequest.setClient('upload', YourNetClient(uploadDio));  // YourNetClient implements INetClient
```

---

## Custom client

Implement `INetClient` (one method: `requestHttp`). Example in the example app: custom upload client with its own Dio and header `X-Client: upload`.

---

## When to use

- Upload / CDN: different baseUrl, timeouts.
- SSE / stream: separate Dio.
- Tests: mock `INetClient`.
- Auth: different interceptors per client.

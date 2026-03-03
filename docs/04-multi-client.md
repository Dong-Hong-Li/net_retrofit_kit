# Multiple clients

**Quick:** Register with `NetRequest.setClient('upload', yourClient)`, use with `@NetApi(client: 'upload')`.

| Step | Do |
|------|-----|
| 1 | Implement `INetClient` (or use `DefaultNetClient(dio)`). |
| 2 | In `main()`: `NetRequest.setClient('upload', UploadNetClient(dio))`. |
| 3 | On API class: `@NetApi(client: 'upload')`. |

Generated code then passes `clientKey: 'upload'`; your client handles the request.

---

## Register

```dart
NetRequest.setClient(String name, INetClient? client);
```

- `name`: same as in `@NetApi(client: 'upload')`.
- `client`: your implementation; `null` to remove.

---

## Use DefaultNetClient

```dart
final uploadDio = NetRequest.createDio(const NetOptions(
  baseUrl: 'https://upload.example.com',
  receiveTimeout: Duration(seconds: 120),
));
NetRequest.setClient('upload', DefaultNetClient(uploadDio));
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

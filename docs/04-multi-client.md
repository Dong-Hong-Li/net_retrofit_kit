# Multiple clients

You can register **named** clients and point specific APIs to them via `@NetApi(client: '...')`. Each client is an [INetClient](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/lib/src/network/inet_client.dart) implementation (e.g. different baseUrl, timeouts, headers, or custom logic).

---

## INetClient

Interface: [lib/src/network/inet_client.dart](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/lib/src/network/inet_client.dart)

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

When generated code calls `NetRequest.requestHttp(..., clientKey: 'upload')`, the package uses the client registered under that key. If none is registered, it falls back to the default implementation (the Dio created from `NetRequest.options`).

---

## Registering a client

[NetRequest](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/lib/src/network/net_request.dart):

```dart
NetRequest.setClient(String name, INetClient? client);
```

- `name`: key (e.g. `'default'`, `'upload'`, `'sse'`). Use the same string in `@NetApi(client: 'upload')`.
- `client`: your `INetClient` implementation. Pass `null` to remove that key.

You can use the built-in [DefaultNetClient](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/lib/src/network/default/default_net_client.dart) by passing a Dio:

```dart
final uploadDio = NetRequest.createDio(const NetOptions(
  baseUrl: 'https://upload.example.com',
  receiveTimeout: Duration(seconds: 120),
));
NetRequest.setClient('upload', DefaultNetClient(uploadDio));
```

---

## Custom client example

The **example app** implements a custom client for uploads instead of reusing `DefaultNetClient`:

- **Class**: [example/lib/network/upload_net_client.dart](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/example/lib/network/upload_net_client.dart) — `UploadNetClient` implements `INetClient`.
- **Behavior**: Uses its own Dio (e.g. longer timeouts), adds a custom header `X-Client: upload`, and handles responses that don’t have a `code` field (e.g. httpbin) as success.
- **Registration**: [example/lib/main.dart](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/example/lib/main.dart) — `NetRequest.setClient('upload', UploadNetClient(uploadDio))`.
- **API**: [example/lib/server/upload_api.dart](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/example/lib/server/upload_api.dart) — `@NetApi(client: 'upload')` so all methods use the upload client.

Generated code for that API passes `clientKey: 'upload'` into `NetRequest.requestHttp`, which then dispatches to `UploadNetClient`.

---

## Flow

1. In `main()` (or before any request): set `NetRequest.options` and call `NetRequest.setClient('upload', yourClient)` for each named client.
2. On the API class: use `@NetApi(client: 'upload')` so the generator emits `clientKey: 'upload'`.
3. At runtime: when a method on that API is called, `requestHttp(..., clientKey: 'upload')` is used and your registered client handles the request.

---

## When to use multiple clients

- **Upload / CDN**: Different baseUrl and timeouts.
- **SSE / streaming**: Separate Dio or client with different options.
- **Tests**: Register a mock `INetClient` for a given key.
- **Auth**: Different clients with different interceptors or headers.

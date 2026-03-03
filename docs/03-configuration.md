# Configuration

Global config is done via [NetRequest](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/lib/src/network/net_request.dart) and [NetOptions](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/lib/src/network/net_options.dart).

---

## NetOptions

Defined in [lib/src/network/net_options.dart](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/lib/src/network/net_options.dart):

```dart
const NetOptions({
  required String baseUrl,
  Duration connectTimeout = const Duration(seconds: 60),
  Duration receiveTimeout = const Duration(seconds: 60),
  Duration sendTimeout = const Duration(seconds: 60),
  List<Interceptor>? interceptors,
});
```

| Field | Description |
|-------|-------------|
| `baseUrl` | Base URL for all requests (generated code uses `baseUrl + path`). |
| `connectTimeout` | Connection timeout. |
| `receiveTimeout` | Receive timeout. |
| `sendTimeout` | Send timeout. |
| `interceptors` | Dio interceptors; added after the default logging interceptor when building the Dio instance. |

---

## Setting the default client (NetRequest.options)

You **must** set `NetRequest.options` before any request. Typically in `main()`:

```dart
void main() {
  NetRequest.options = const NetOptions(
    baseUrl: 'https://api.example.com',
    connectTimeout: Duration(seconds: 30),
    receiveTimeout: Duration(seconds: 30),
    sendTimeout: Duration(seconds: 30),
    interceptors: [/* optional */],
  );
  runApp(const MyApp());
}
```

Setting `options` creates a new Dio instance (via [NetRequest.createDio](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/lib/src/network/net_request.dart)) and uses it for the **default** client. If you don’t set it, `NetRequest.options` or the first request will throw a `StateError`.

---

## createDio and custom Dio

[NetRequest.createDio(NetOptions options)](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/lib/src/network/net_request.dart) builds a Dio with:

- `BaseOptions` from the given `NetOptions`
- The package’s default logging interceptor
- Any `interceptors` from `NetOptions`

You can use `createDio` to build a Dio for a **named** client (e.g. upload) and then wrap it in your own [INetClient](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/lib/src/network/inet_client.dart) or [DefaultNetClient](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/lib/src/network/default/default_net_client.dart):

```dart
final uploadDio = NetRequest.createDio(const NetOptions(
  baseUrl: 'https://upload.example.com',
  receiveTimeout: Duration(seconds: 120),
));
NetRequest.setClient('upload', DefaultNetClient(uploadDio));
```

You can also build a Dio yourself (different baseUrl, interceptors, etc.) and pass it to your custom client; see [docs/04-multi-client.md](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/docs/04-multi-client.md).

---

## Interceptors

- **Default**: When you set `NetRequest.options` or call `NetRequest.createDio`, the package adds its [HttpLoggingInterceptor](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/lib/src/network/http_logging_interceptor.dart) first.
- **Your interceptors**: Pass them in `NetOptions.interceptors`; they are appended after the logging one.
- **Runtime**: After the Dio instance exists, you can call `NetRequest.addInterceptor(interceptor)` or `NetRequest.addInterceptors(list)` to add more.

---

## Using an existing Dio (e.g. tests)

For tests or when you already have a configured Dio:

```dart
NetRequest.dioInstance = myDio;  // or NetRequest.use(myDio)
```

You must still ensure `NetRequest.options` is set if generated code or other code reads `NetRequest.options.baseUrl`. For tests, you can set `options` to a dummy `NetOptions` and then override with `dioInstance` if you only need to mock the HTTP client.

---

## Summary

| What | How |
|------|-----|
| Default baseUrl + timeouts | `NetRequest.options = NetOptions(...)` once before requests |
| Extra interceptors | `NetOptions.interceptors` or `NetRequest.addInterceptor` / `addInterceptors` |
| New Dio for a named client | `NetRequest.createDio(NetOptions(...))` then `setClient(name, client)` |
| Replace Dio (e.g. test) | `NetRequest.dioInstance = dio` |

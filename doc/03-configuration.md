# Configuration

**Quick lookup:**

| Need | How |
|------|-----|
| Default baseUrl + timeouts | `NetRequest.options = NetOptions(...)` once before any request |
| Extra interceptors | `NetOptions.interceptors` or `NetRequest.addInterceptor` / `addInterceptors` |
| Dio for a named client | `NetRequest.createDio(NetOptions(...))` then `setClient(name, client)` |
| Replace Dio (e.g. test) | `NetRequest.dioInstance = myDio` |

---

## NetOptions

```dart
const NetOptions({
  required String baseUrl,
  Duration connectTimeout = Duration(seconds: 60),
  Duration receiveTimeout = Duration(seconds: 60),
  Duration sendTimeout = Duration(seconds: 60),
  List<Interceptor>? interceptors,
});
```

| Field | Use |
|-------|-----|
| `baseUrl` | Base URL; generated code uses `baseUrl + path`. |
| `connectTimeout` / `receiveTimeout` / `sendTimeout` | Timeouts. |
| `interceptors` | Added after default logging interceptor. |

---

## Set default (required)

```dart
void main() {
  NetRequest.options = const NetOptions(
    baseUrl: 'https://api.example.com',
    connectTimeout: Duration(seconds: 30),
    receiveTimeout: Duration(seconds: 30),
    sendTimeout: Duration(seconds: 30),
  );
  runApp(const MyApp());
}
```

Must run before first request.

---

## createDio (for named client)

```dart
final uploadDio = NetRequest.createDio(const NetOptions(
  baseUrl: 'https://upload.example.com',
  receiveTimeout: Duration(seconds: 120),
));
NetRequest.setClient('upload', YourNetClient(uploadDio));  // implement INetClient yourself; example app has a reference
```

---

## Interceptors

- Default: logging interceptor is added when building Dio.
- Yours: `NetOptions.interceptors` or later `NetRequest.addInterceptor(interceptor)`.

---

## Logging (curl)

Request logging is done by the default interceptor. You can tune it via `HttpLogger`:

| Item | Use |
|------|-----|
| `HttpLogger.logLevel` | `LogLevel.none` / `basic` (URL+method) / `headers` / `body` (full curl). |
| `HttpLogger.defaultEnableLogging` | Whether logging is on by default (e.g. `true` in debug). |
| `HttpLogger.curlSingleLineCopy` | When `true` (default), after the multi-line curl a **single-line** curl is printed so you can copy it in one go and paste into a terminal. Set to `false` to only show the multi-line curl. |

---

## Test: inject Dio

```dart
NetRequest.dioInstance = myDio;  // or NetRequest.use(myDio)
```

Set `NetRequest.options` first if code reads `NetRequest.options.baseUrl`.

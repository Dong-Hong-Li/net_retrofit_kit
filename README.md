[中文](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/README_zh.md) | **English**

---

[![pub package](https://img.shields.io/pub/v/net_retrofit_kit.svg)](https://pub.dev/packages/net_retrofit_kit)
[![License](https://img.shields.io/badge/license-Artistic%202.0-blue.svg)](LICENSE)

# net_retrofit_kit

Retrofit-style HTTP API for Flutter with **annotations and code generation**. Define abstract API classes with `@NetApi`, annotate methods with `@Get` / `@Post` / `@Put` / `@Delete`, then generate implementation that calls your `NetRequest` or custom `INetClient`. Configurable: multiple clients, response type, unwrap success.

**Repository**

| Link | URL |
|------|-----|
| **GitHub** | [github.com/Dong-Hong-Li/net_retrofit_kit](https://github.com/Dong-Hong-Li/net_retrofit_kit) |
| **Clone** | `git clone https://github.com/Dong-Hong-Li/net_retrofit_kit.git` |

---

## Quick start

1. **Dependencies** — [pubspec.yaml](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/pubspec.yaml)

```yaml
dependencies:
  net_retrofit_kit: ^0.1.0
  dio: ">=5.0.0"
dev_dependencies:
  build_runner: ^2.4.0
```

2. **Configure once** (e.g. in `main()`)

```dart
NetRequest.options = const NetOptions(
  baseUrl: 'https://api.example.com',
  connectTimeout: Duration(seconds: 30),
  receiveTimeout: Duration(seconds: 30),
);
```

3. **Define API** — abstract class + annotations

```dart
@NetApi()
abstract class UserApi {
  static UserApi get instance => UserApiImpl();
  @Get('/user/info')
  Future<UserModel?> getUserInfo();
  @Post('/login')
  Future<AuthModel?> login(@Body() LoginRequest body);
}
```

4. **Generate** — `dart run build_runner build --delete-conflicting-outputs`  
5. **Use** — `await UserApi.instance.getUserInfo();`

---

## Documentation (with GitHub links)

| Doc | Description |
|-----|-------------|
| [docs/01-getting-started.md](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/docs/01-getting-started.md) | Full getting started: dependency, config, API definition, build, usage |
| [docs/02-annotations.md](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/docs/02-annotations.md) | Annotation reference: `@NetApi`, `@Get`/`@Post`/…, `@Body`, `@Query`/`@QueryKey`, `@Path`, `@Header`, `@DataPath`, `@Part`, `@StreamResponse` |
| [docs/03-configuration.md](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/docs/03-configuration.md) | Configuration: `NetOptions`, `NetRequest.options`, interceptors, `createDio` |
| [docs/04-multi-client.md](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/docs/04-multi-client.md) | Multiple clients: `INetClient`, `setClient`, `@NetApi(client: 'xxx')`, custom client example |
| [docs/05-example.md](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/docs/05-example.md) | Example app: structure, cases, run instructions |

---

## Key source files (GitHub)

| File | Description |
|------|-------------|
| [lib/net_retrofit_kit.dart](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/lib/net_retrofit_kit.dart) | Library exports |
| [lib/src/generate/annotations.dart](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/lib/src/generate/annotations.dart) | All annotations (`NetApi`, `Get`, `Post`, `Body`, etc.) |
| [lib/src/network/net_request.dart](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/lib/src/network/net_request.dart) | `NetRequest` (options, setClient, requestHttp) |
| [lib/src/network/net_options.dart](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/lib/src/network/net_options.dart) | `NetOptions` |
| [lib/src/network/inet_client.dart](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/lib/src/network/inet_client.dart) | `INetClient` interface |
| [lib/src/network/default/default_net_client.dart](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/lib/src/network/default/default_net_client.dart) | Default `INetClient` implementation |
| [example/lib/main.dart](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/example/lib/main.dart) | Example app entry, config, custom client registration |
| [example/lib/network/upload_net_client.dart](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/example/lib/network/upload_net_client.dart) | Custom client example (implements `INetClient`) |
| [example/lib/server/upload_api.dart](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/example/lib/server/upload_api.dart) | API using custom client: `@NetApi(client: 'upload')` |

---

## Example app

```bash
cd example
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

Example directory: [example/](https://github.com/Dong-Hong-Li/net_retrofit_kit/tree/main/example)

---

## Topics

flutter · networking · retrofit · code-generation · dio · annotations

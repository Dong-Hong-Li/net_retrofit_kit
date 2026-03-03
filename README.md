[中文](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/README_zh.md) | **English**

[![pub](https://img.shields.io/pub/v/net_retrofit_kit.svg)](https://pub.dev/packages/net_retrofit_kit) [![License](https://img.shields.io/badge/license-Artistic%202.0-blue.svg)](LICENSE)

# net_retrofit_kit

Declarative HTTP client for Flutter: **annotations + codegen**, based on Dio. [GitHub](https://github.com/Dong-Hong-Li/net_retrofit_kit)

---

## Quick start

**1. Dependencies**

```yaml
dependencies:
  net_retrofit_kit: ^0.1.0
  dio: ">=5.0.0"
dev_dependencies:
  build_runner: ^2.4.0
```

**2. Config** (once, e.g. in `main()`)

```dart
NetRequest.options = const NetOptions(
  baseUrl: 'https://api.example.com',
  connectTimeout: Duration(seconds: 30),
  receiveTimeout: Duration(seconds: 30),
);
```

**3. Define API**

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

**4. Generate**  
`dart run build_runner build --delete-conflicting-outputs`

**5. Use**  
`await UserApi.instance.getUserInfo();`

---

## Quick reference (annotations)

| Annotation | Use |
|------------|-----|
| `@NetApi()` | On abstract class. Optional: `client: 'upload'` for named client. |
| `@Get(path)` `@Post(path)` `@Put(path)` `@Delete(path)` | HTTP method + path. |
| `@Body()` | Request body. |
| `@Query()` | Full query map. `@QueryKey('name')` = single query param. |
| `@Path('id')` | Path param for `:id` in path. |
| `@Header('Authorization')` | Request header. |
| `@DataPath('key')` | Parse from `response.data['key']`. |
| `@Part('file')` | Multipart part (with `ContentType.formData`). |
| `@StreamResponse()` | Return stream (SSE / line stream). |

More: [Annotations](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/doc/02-annotations.md) · [Configuration](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/doc/03-configuration.md) · [Multiple clients](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/doc/04-multi-client.md) · [Example](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/doc/05-example.md)

---

## Run example

```bash
cd example && flutter pub get && dart run build_runner build --delete-conflicting-outputs && flutter run
```

[Example project](https://github.com/Dong-Hong-Li/net_retrofit_kit/tree/main/example)

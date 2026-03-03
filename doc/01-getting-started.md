# Getting started

**Quick:** Add dependency → set `NetRequest.options` in `main()` → register at least one client (implement [INetClient](04-multi-client.md); example app has a copyable default implementation) → define `@NetApi()` abstract class → run build_runner → use `XxxImpl()`.

---

## 1. Dependencies

```yaml
dependencies:
  net_retrofit_kit: ^0.1.0
  dio: ">=5.0.0"
dev_dependencies:
  build_runner: ^2.4.0
```

`flutter pub get`

---

## 2. Config (once)

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  NetRequest.options = const NetOptions(
    baseUrl: 'https://api.example.com',
    connectTimeout: Duration(seconds: 30),
    receiveTimeout: Duration(seconds: 30),
    sendTimeout: Duration(seconds: 30),
  );
  runApp(const MyApp());
}
```

Must run before any request.

---

## 3. Define API

- Abstract class + `@NetApi()` (optional `client: 'upload'`; else uses [NetRequest.defaultKey](04-multi-client.md#defaultkey)).
- Methods: `@Get(path)`, `@Post(path)`, etc.
- Params: `@Body()`, `@QueryKey('name')`, `@Path('id')`, `@Header('name')` as needed.
- Return: `Future<T?>` (T with `fromJson`) or `Future<bool?>`.
- Static getter returns generated class: `UserApiImpl`.

```dart
part 'user_api.g.dart';

@NetApi()
abstract class UserApi {
  static UserApi get instance => UserApiImpl();
  @Get('/user/info')
  Future<UserModel?> getUserInfo();
  @Post('/login')
  Future<AuthModel?> login(@Body() LoginRequest body);
  @Get('/user/:id')
  Future<UserModel?> getUser(@Path('id') String id);
}
```

---

## 4. Generate

```bash
dart run build_runner build --delete-conflicting-outputs
```

Generates `user_api.g.dart` with `UserApiImpl`. Re-run after changing API or annotations.

---

## 5. Use

```dart
await UserApi.instance.getUserInfo();
await UserApi.instance.login(LoginRequest(phone: '138'));
await UserApi.instance.getUser('123');
```

---

[Annotations](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/doc/02-annotations.md) · [Configuration](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/doc/03-configuration.md) · [Multiple clients](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/doc/04-multi-client.md) · [Example](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/doc/05-example.md)

# Getting started

Full step-by-step to add net_retrofit_kit to your Flutter app.

---

## 1. Add dependencies

In your app’s [pubspec.yaml](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/pubspec.yaml):

```yaml
dependencies:
  net_retrofit_kit: ^0.1.0
  dio: ">=5.0.0"

dev_dependencies:
  build_runner: ^2.4.0
```

For local development: `net_retrofit_kit: path: ../net_retrofit_kit`.

Run:

```bash
flutter pub get
```

---

## 2. Configure before any request

Set [NetRequest.options](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/lib/src/network/net_request.dart) once, e.g. in `main()`:

```dart
import 'package:net_retrofit_kit/net_retrofit_kit.dart';

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

If you don’t set `NetRequest.options`, the first request will throw a `StateError`. See [docs/03-configuration.md](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/docs/03-configuration.md) for more options (interceptors, etc.).

---

## 3. Define your API (abstract class + annotations)

Create a Dart file (e.g. `lib/api/user_api.dart`) and define an **abstract** class with [annotations](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/lib/src/generate/annotations.dart):

```dart
import 'package:net_retrofit_kit/net_retrofit_kit.dart';

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

  @Get('/search')
  Future<List<Item>?> search(@QueryKey('keyword') String keyword, @QueryKey('page') int page);
}
```

- **Class**: Must be `abstract`, with `@NetApi()` (optional: `@NetApi(client: 'upload')` for a named client).
- **Methods**: Annotate with `@Get(path)`, `@Post(path)`, etc. Use `@Body()`, `@Query()`, `@QueryKey(name)`, `@Path(name)`, `@Header(name)` on parameters as needed.
- **Return type**: `Future<T?>` where `T` has `fromJson` for JSON parsing, or `Future<bool?>` for success-only.

The static getter (e.g. `instance`) should return the **generated** implementation class name (`UserApiImpl`). The generator produces a class named `{ClassName}Impl` in the same file’s `.g.dart`.

---

## 4. Generate implementation

From your **app** root (where `pubspec.yaml` and `build.yaml` are):

```bash
dart run build_runner build --delete-conflicting-outputs
```

This generates `user_api.g.dart` (or `user_api.net_retrofit_kit.g.part` depending on [build.yaml](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/build.yaml)) with `UserApiImpl` that calls `NetRequest.requestHttp` (or the client specified by `@NetApi(client: '...')`).

After changing annotations or method signatures, run the same command again.

---

## 5. Use in your app

```dart
final user = await UserApi.instance.getUserInfo();
final auth = await UserApi.instance.login(LoginRequest(phone: '13800138000'));
final u = await UserApi.instance.getUser('123');
final list = await UserApi.instance.search('flutter', 1);
```

No need to write implementation classes or repetitive `NetRequest.requestHttp` + `BaseResponse.fromJson` by hand.

---

## Next steps

- [Annotation reference](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/docs/02-annotations.md) — all annotations and examples.
- [Configuration](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/docs/03-configuration.md) — `NetOptions`, interceptors, `createDio`.
- [Multiple clients](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/docs/04-multi-client.md) — `INetClient`, `setClient`, custom client.
- [Example app](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/docs/05-example.md) — run and browse the sample project.

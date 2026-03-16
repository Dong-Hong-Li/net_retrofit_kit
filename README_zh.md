[English](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/README.md) | **中文**

[![pub](https://img.shields.io/pub/v/net_retrofit_kit.svg)](https://pub.dev/packages/net_retrofit_kit) [![License](https://img.shields.io/badge/license-Artistic%202.0-blue.svg)](LICENSE)

# net_retrofit_kit

声明式 HTTP 客户端：**注解 + 代码生成**，基于 Dio。[GitHub](https://github.com/Dong-Hong-Li/net_retrofit_kit)

---

## 快速开始

**1. 依赖**

```yaml
dependencies:
  net_retrofit_kit: ^0.2.11
  dio: ">=5.0.0"
dev_dependencies:
  build_runner: ^2.4.0
```

**2. 配置**（一次，如在 `main()`）

```dart
NetRequest.options = const NetOptions(
  baseUrl: 'https://api.example.com',
  connectTimeout: Duration(seconds: 30),
  receiveTimeout: Duration(seconds: 30),
);
```

**3. 定义 API**

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

**4. 生成**  
`dart run build_runner build --delete-conflicting-outputs`

**5. 调用**  
`await UserApi.instance.getUserInfo();`

---

## 速查（注解）

| 注解 | 用途 |
|------|------|
| `@NetApi()` | 标在抽象类上。可选 `client: 'upload'` 使用具名 Client；否则走 [NetRequest.defaultKey](doc/04-多Client.md)。 |
| `@Get(path)` `@Post(path)` `@Put(path)` `@Delete(path)` | HTTP 方法 + 路径。 |
| `@Body()` | 请求体。可为 `Map<String, dynamic>` 或 class model；非 Map 时生成器会生成 `body.toJson()`，模型须实现 `toJson`。 |
| `@Query()` | 完整 query map。`@QueryKey('name')` 单个 query 参数。 |
| `@Path('id')` | 路径参数，path 中写 `:id`。 |
| `@Header('Authorization')` | 请求头。 |
| `@DataPath('key')` | 从 `response.data['key']` 解析。 |
| `@Part('file')` | 多部分表单（配合 `ContentType.formData`）。 |
| `@StreamResponse()` | 返回流（SSE / 按行）。 |

更多：[注解说明](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/doc/02-注解说明.md) · [配置](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/doc/03-配置.md) · [多 Client](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/doc/04-多Client.md) · [示例](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/doc/05-示例.md)

---

## 运行示例

```bash
cd example && flutter pub get && dart run build_runner build --delete-conflicting-outputs && flutter run
```

[示例工程](https://github.com/Dong-Hong-Li/net_retrofit_kit/tree/main/example)

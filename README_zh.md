[English](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/README.md) | **中文**

---

[![pub package](https://img.shields.io/pub/v/net_retrofit_kit.svg)](https://pub.dev/packages/net_retrofit_kit)
[![License](https://img.shields.io/badge/license-Artistic%202.0-blue.svg)](LICENSE)

# net_retrofit_kit

基于 Dio 的**声明式 HTTP 客户端**：用注解定义 API 接口并自动生成实现，少写样板代码；支持多 Client、自定义响应解析与统一错误处理。

**仓库**

| 链接 | 地址 |
|------|------|
| **GitHub** | [github.com/Dong-Hong-Li/net_retrofit_kit](https://github.com/Dong-Hong-Li/net_retrofit_kit) |
| **克隆** | `git clone https://github.com/Dong-Hong-Li/net_retrofit_kit.git` |

---

## 快速开始

1. **依赖** — [pubspec.yaml](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/pubspec.yaml)

```yaml
dependencies:
  net_retrofit_kit: ^0.1.0
  dio: ">=5.0.0"
dev_dependencies:
  build_runner: ^2.4.0
```

2. **启动时配置**（如在 `main()` 中）

```dart
NetRequest.options = const NetOptions(
  baseUrl: 'https://api.example.com',
  connectTimeout: Duration(seconds: 30),
  receiveTimeout: Duration(seconds: 30),
);
```

3. **定义 API** — 抽象类 + 注解

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

4. **生成** — `dart run build_runner build --delete-conflicting-outputs`  
5. **调用** — `await UserApi.instance.getUserInfo();`

---

## 详细文档（含 GitHub 链接）

| 文档 | 说明 |
|------|------|
| [docs/01-快速开始.md](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/docs/01-快速开始.md) | 完整上手：依赖、配置、定义 API、生成、使用 |
| [docs/02-注解说明.md](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/docs/02-注解说明.md) | 注解一览：`@NetApi`、`@Get`/`@Post`/…、`@Body`、`@Query`/`@QueryKey`、`@Path`、`@Header`、`@DataPath`、`@Part`、`@StreamResponse` |
| [docs/03-配置.md](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/docs/03-配置.md) | 配置说明：`NetOptions`、`NetRequest.options`、拦截器、`createDio` |
| [docs/04-多Client.md](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/docs/04-多Client.md) | 多 Client：`INetClient`、`setClient`、`@NetApi(client: 'xxx')`、自定义 Client 示例 |
| [docs/05-示例.md](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/docs/05-示例.md) | 示例工程：目录结构、各案例说明、运行方式 |

---

## 主要源码（GitHub）

| 文件 | 说明 |
|------|------|
| [lib/net_retrofit_kit.dart](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/lib/net_retrofit_kit.dart) | 库导出入口 |
| [lib/src/generate/annotations.dart](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/lib/src/generate/annotations.dart) | 全部注解定义（`NetApi`、`Get`、`Post`、`Body` 等） |
| [lib/src/network/net_request.dart](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/lib/src/network/net_request.dart) | `NetRequest`（options、setClient、requestHttp） |
| [lib/src/network/net_options.dart](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/lib/src/network/net_options.dart) | `NetOptions` |
| [lib/src/network/inet_client.dart](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/lib/src/network/inet_client.dart) | `INetClient` 接口 |
| [lib/src/network/default/default_net_client.dart](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/lib/src/network/default/default_net_client.dart) | 默认 `INetClient` 实现 |
| [example/lib/main.dart](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/example/lib/main.dart) | 示例入口、配置、自定义 Client 注册 |
| [example/lib/network/upload_net_client.dart](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/example/lib/network/upload_net_client.dart) | 自定义 Client 示例（实现 `INetClient`） |
| [example/lib/server/upload_api.dart](https://github.com/Dong-Hong-Li/net_retrofit_kit/blob/main/example/lib/server/upload_api.dart) | 使用自定义 Client 的 API：`@NetApi(client: 'upload')` |

---

## 运行示例

```bash
cd example
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

示例目录：[example/](https://github.com/Dong-Hong-Li/net_retrofit_kit/tree/main/example)

---

## 分类标签

flutter · networking · retrofit · code-generation · dio · annotations

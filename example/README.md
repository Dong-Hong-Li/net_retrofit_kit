# net_retrofit_kit 可运行示例

本目录是一个完整的 Flutter 应用，用于验证 `net_retrofit_kit` 的配置、代码生成与多案例请求。

## 命令行：创建与运行

```bash
# 1. 进入示例目录
cd example

# 2. 拉取依赖（含对上级 net_retrofit_kit 的 path 依赖）
flutter pub get

# 3. 生成 .g.dart（必须，否则运行报错）
dart run build_runner build --delete-conflicting-outputs

# 4. 运行应用
flutter run
```

（需在 `example` 目录下执行，或使用 `flutter run -C /path/to/net_retrofit_kit/example`）

## 全部案例说明

首页点击 **「全部案例（多案例入口）」** 进入多案例页，可逐项发起请求并查看结果。

| 案例 | 文件 | 注解与用法 |
|------|------|------------|
| 1 基础 API | `server/demo_server.dart` | `@Get` / `@Post`、`@Body`、`@StreamResponse`、流式 `getStreamLines` |
| 2 User API | `server/user_api.dart` | `@QueryKey`、`@Path`、`@Header`、`@Query()` Map |
| 3 Article API | `server/article_api.dart` | `@Post` `@Body`、`@Put`、`@Delete` + `@Path('id')` |
| 4 Upload API | `server/upload_api.dart` | `ContentType.formData` + `@Part('file')` / `@Part('name')` |
| 5 Nested API | `server/nested_api.dart` | `@DataPath('result')` 从 `data[path]` 解析 |

- **目录结构**：`lib/main.dart` 入口；`lib/pages/` 页面（全部案例、流式请求）；`lib/server/` API 定义与模型。
- **main.dart**：设置 `NetRequest.options`（baseUrl: https://httpbin.org），首页保留快速体验按钮与「全部案例」入口。
- **流式请求**：在案例 1 中进入「流式 getStreamLines」或首页「流式请求示例」，请求 `httpbin.org/stream/3`，演示 [CancelToken] 与按行消费。

## 代码生成

- 所有带 `@NetApi()` 的抽象类由 `net_retrofit_kit` 的生成器生成实现类（`XxxImpl`），输出到同名的 `.g.dart`。
- 修改 `server/*.dart` 中接口或注解后，需重新执行：  
  `dart run build_runner build --delete-conflicting-outputs`。

## 依赖关系

- `example` 通过 `path: ..` 依赖 `net_retrofit_kit`；`dev_dependencies` 含 `build_runner`、`build`、`source_gen` 用于代码生成。

# NetKit retrofit 风格注解与生成契约

## 目标

将手写的一坨 `NetRequest.requestHttp` + `response?.isSuccess` + `Model.fromJson` + `.execute(options)` 收敛为**声明式接口 + 代码生成**，风格贴近 Retrofit，包内可极致定制（Client / BaseResponse / execute 包装均可配置）。

## 定制化参数（@NetApi）

| 参数 | 含义 | 默认 |
|------|------|------|
| `client` | 发起请求的类名 | `NetRequest` |
| `responseType` | 统一响应类型 | `BaseResponse` |
| `executeWrapper` | 执行包装（loading/异常） | `RequestHelper.execute` |
| `unwrapSuccess` | 成功时只返回 data 还是整份 response | `true` |

生成代码会调用：`Client.requestHttp`、用 `ResponseType.fromJson(..., dataParser: parser)` 解析，再按需用 `(() async { ... }).execute(options: options)` 包装。

## 注解与用法

- **@NetApi(...)**：标在抽象类上。
- **@Get(path)** / **@Post(path)** / **@Put(path)** / **@Delete(path)**：标在方法上，path 为相对路径。
- **@Body()**：该参数作为请求体，生成代码传 `body: param.toJson()` 或 `body: param`（Map），对应 Retrofit @Body。
- **@Query()**：该参数作为 Query 整体（Map），生成代码传 `queryParameters: param`，对应 Retrofit @QueryMap。
- **@QueryKey(name)**：单参数对应 query 的 key，对应 Retrofit @Query。
- **@DataPath('archive')**：从 `response.data['archive']` 解析模型，而不是直接用 `response.data`。

方法签名约定（指定什么就接什么，按返回类型生成）：

- 返回 `Future<T?>` 且 T 有 `fromJson`：生成 `parser: (json) => T.fromJson(json)`，成功时返回 `T?`。
- 返回 `Future<bool?>`：生成只判断 `response?.isSuccess`，不解析 data。
- 最后一个可选参数 `RequestOptions? options`：会传入生成的 `.execute(options: options)`。

## 示例：手写 → 注解 + 生成

### 手写（当前）

```dart
Future<UserAuthModel?> login(String mobile, {RequestOptions? options}) async {
  return await (() async {
    final response = await NetRequest.requestHttp<Map<String, dynamic>>(
      url: UserAuthApi.login,
      method: HttpMethod.post,
      body: {'phone': mobile},
    );
    if (response?.isSuccess == true && response?.data != null) {
      return UserAuthModel.fromJson(response!.data!);
    }
    return null;
  }).execute(options: options);
}
```

### 注解声明（生成器输入）

```dart
import 'package:net_kit/net_kit.dart';
import 'package:fate_map/core/network/response/http_constant.dart';
import 'package:fate_map/core/provider/user_auth/model/user_auth_model.dart';
// ...

@NetApi()
abstract class UserAuthServer {
  static UserAuthServer get instance => _UserAuthServerImpl();

  @Post('/login')
  Future<UserAuthModel?> login(String mobile, {RequestOptions? options});

  @Get('/user/info')
  Future<UserAuthModel?> getUserInfo({RequestOptions? options});

  @Post('/user/google-login')
  Future<UserAuthModel?> googleLogin(String googleToken, {RequestOptions? options});

  @Post('/archives/save')
  Future<bool?> saveArchives(SaveArchivesRequestModel request, {RequestOptions? options});

  @Get('/archives/detail')
  @DataPath('archive')
  Future<ArchiveModel?> getArchives({RequestOptions? options});
}
```

### 生成代码（生成器输出，对标手写逻辑）

见仓库内 `lib/core/provider/user_auth/server/user_auth_server.g.dart` 示例。

## 生成器需要做的事

1. 扫描带 `@NetApi` 的抽象类，收集带 `@Get`/`@Post`/… 的抽象方法。
2. 对每个方法生成实现：根据 path、method、参数（@Body → body，@Query / @QueryKey → queryParameters）拼 `url`；根据返回类型选 `parser` 或 `@DataPath`；若配置了 `executeWrapper` 则包一层 `.execute(options: options)`。
3. 生成实现类名建议：`_${ApiName}Impl`，单例 getter 与抽象类中 static getter 一致（如 `instance`）。

## 依赖与包结构

- **net_kit**（本包）：仅注解 + 文档契约，无运行时依赖 Dio。
- **业务项目**：依赖 net_kit，并依赖 dio、你的 NetRequest/BaseResponse/RequestHelper。
- **net_kit_builder**（可选）：单独包，依赖 build_runner + source_gen，实现上述生成逻辑；或在业务项目里用 build_runner 直接写 Builder。

这样你的网络层保持「NetRequest + BaseResponse + execute」不变，只是从手写 Server 变为「注解 + 生成」，包可极致定制。

---

## 配置如何传入（设计）

目标：**由业务方把配置传进包内**，包不依赖业务层的 `Apis` 等类。

### 设计要点

1. **包内定义「配置类型」和「注入入口」**  
   - 在 net_retrofit_kit 里提供 `NetOptions`（或 `NetConfig`），包含 baseUrl、timeout 等。  
   - 提供唯一注入点：`NetRequest.init(NetOptions options)`（或 `NetConfig.init(...)`），**只允许在 App 启动时调用一次**。

2. **业务方负责传入**  
   - 在 `main()` 或早于任何网络请求的地方调用：  
     `NetRequest.init(NetOptions(baseUrl: 'https://api.xxx.com', ...))`。  
   - 配置从外往里传，包内不引用任何业务类。

3. **包内只读已注入的配置**  
   - `NetRequest` 内部不再写死 baseUrl，也不依赖 `Apis`，只读 `_options.baseUrl` 等。  
   - 若未 init 就发起请求，可抛 `StateError('请先调用 NetRequest.init(NetOptions(...))')`，并在文档中约定「必须先 init」。

### 数据流（谁传、谁接）

```
业务 main()  →  NetRequest.init(NetOptions(...))  →  包内保存 _options
                                                          ↓
生成代码 / NetRequest.requestHttp()  ←  只读 _options.baseUrl 等
```

这样设计后，配置的传递路径是单向的：**业务方通过 init 把配置泵进包内**，包内只读、不再反向依赖业务。

# 配置传递方案

针对 Net Retrofit Kit 中 baseUrl、timeout、Client、executeWrapper 等配置，下面几种方式可单独或组合使用。

---

## 方案一：全局配置单例（简单、适合单环境）

**思路**：定义一个 `NetConfig` 单例，App 启动时初始化，`NetRequest` 内部只读该单例。

```dart
// lib/src/network/net_config.dart
class NetConfig {
  NetConfig._();
  static NetConfig? _instance;
  static NetConfig get instance => _instance ??= NetConfig._();

  String baseUrl = '';
  Duration connectTimeout = const Duration(seconds: 60);
  Duration receiveTimeout = const Duration(seconds: 60);
  String? defaultToken;

  static void init({
    required String baseUrl,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    String? defaultToken,
  }) {
    instance.baseUrl = baseUrl;
    if (connectTimeout != null) instance.connectTimeout = connectTimeout;
    if (receiveTimeout != null) instance.receiveTimeout = receiveTimeout;
    if (defaultToken != null) instance.defaultToken = defaultToken;
  }
}
```

**NetRequest 使用**：`BaseOptions(baseUrl: NetConfig.instance.baseUrl, ...)`。

**优点**：调用方无需传参，改一处即可。  
**缺点**：全局状态，多 baseUrl/多环境需配合其他方式（如方案二或方案五）。

---

## 方案二：Options 对象 + 静态 init（一次性注入）

**思路**：用不可变 `NetOptions` 在启动时传给 `NetRequest`，内部保存一份，之后只读。

```dart
class NetOptions {
  const NetOptions({
    required this.baseUrl,
    this.connectTimeout = const Duration(seconds: 60),
    this.receiveTimeout = const Duration(seconds: 60),
    this.executeWrapper,
    this.responseType,
  });
  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final String? executeWrapper;  // 与 @NetApi 对齐
  final String? responseType;
}

class NetRequest {
  static NetOptions? _options;
  static void init(NetOptions options) => _options = options;
  static NetOptions get options => _options ?? throw StateError('NetRequest.init() 未调用');

  static final Dio _dio = Dio(); // 或 init 里根据 options 创建
}
```

**优点**：配置不可变、类型清晰，测试时 `NetRequest.init(NetOptions(baseUrl: 'http://test'))` 即可。  
**缺点**：运行时只能一套配置，换环境需重新 init 或新进程。

---

## 方案三：依赖注入（多 Client / 多环境）

**思路**：不依赖静态 `NetRequest`，而是把「谁发请求」和「baseUrl 等」通过构造函数注入到具体 API 实现或一个统一的 Client 里。

```dart
abstract class HttpClient {
  Future<BaseResponse<T>?> request<T>({...});
}

class DioClient implements HttpClient {
  DioClient({required this.baseUrl, required this.options});
  final String baseUrl;
  final NetOptions options;
  // ...
}

// 生成器生成的实现类接受 Client
class UserAuthServerImpl implements UserAuthServer {
  UserAuthServerImpl(this._client);
  final HttpClient _client;
  // 生成代码用 _client.request(...) 而不是 NetRequest.requestHttp
}
```

**优点**：多环境、多 baseUrl、测试 mock 都很自然，符合 DI 习惯。  
**缺点**：需要生成器支持「从 @NetApi(client: ...) 或注入点拿到 Client」，调用方要拿到已注入的 Server 实例（如从 GetIt 取）。

---

## 方案四：注解参数（与生成器契约一致）

**思路**：沿用现有 `@NetApi(client: 'NetRequest', responseType: 'BaseResponse', ...)`，把「用哪套配置」通过注解表达；baseUrl 等仍由 NetRequest 内部从单例/options 读，注解只管「用哪个 Client / 哪个包装」。

```dart
@NetApi(
  client: 'NetRequest',
  responseType: 'BaseResponse',
  executeWrapper: 'RequestHelper.execute',
  unwrapSuccess: true,
)
abstract class UserAuthServer { ... }
```

若需**按 API 区分 baseUrl**，可扩展注解，例如：

```dart
@NetApi(baseUrlKey: 'auth')  // 生成器或运行时从 NetConfig.getBaseUrl('auth') 取
abstract class UserAuthServer { ... }
```

**优点**：声明式、与现有设计一致，生成器易扩展。  
**缺点**：baseUrl 等若也走注解，需要约定好「key → 实际 URL」的提供方（如方案一/二）。

---

## 方案五：环境 / Flavor 约定（多环境一把梭）

**思路**：不同 flavor（dev/qa/prod）或环境变量在编译/启动时选不同配置，配置来自常量或单例，NetRequest 只读「当前环境」的那一份。

```dart
enum Env { dev, qa, prod }

class EnvConfig {
  static Env _env = Env.prod;
  static set env(Env e) => _env = e;
  static String get baseUrl => _map[_env]!;
  static const _map = {
    Env.dev: 'https://dev.example.com',
    Env.qa: 'https://qa.example.com',
    Env.prod: 'https://api.example.com',
  };
}

// main_dev.dart: EnvConfig.env = Env.dev; runApp(...);
```

**优点**：多环境清晰，改环境不改业务代码。  
**缺点**：仍是「全局当前环境」，同一进程内多 baseUrl 要再叠方案二/三。

---

## 推荐组合

| 场景 | 建议 |
|------|------|
| 单环境、简单接入 | 方案一（单例）或 方案二（init + Options） |
| 多环境（dev/qa/prod） | 方案五定环境，方案一/二存当前 baseUrl 等 |
| 多 Client / 强测试 / 多 baseUrl 并存 | 方案三（DI）+ 方案四（注解里 client 指向注入的 Client） |
| 与生成器、@NetApi 对齐 | 方案四保留并扩展；具体 baseUrl 由方案一/二/五 提供 |

当前包内 `NetRequest` 使用 `Apis.baseUrl`，等价于「调用方通过 Apis 提供配置」；若希望包内自洽，可引入方案一或方案二，在文档中约定：App 启动时调用 `NetConfig.init(...)` 或 `NetRequest.init(NetOptions(...))`，再使用生成的 API。

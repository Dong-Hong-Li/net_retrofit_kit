# Net Retrofit Kit 注解设计文档

本文档基于 [net_kit_retrofit_style.md](net_kit_retrofit_style.md) 的契约，与 **lib/src/network**（[INetClient.requestHttp]、[NetRequest.requestHttp]）一一对应。  
注解与请求参数的映射见 **lib/src/generate/annotations.dart** 内注释。

---

## 一、注解总览（与 network 对应）

| 注解 | 作用对象 | 对应 requestHttp 参数 / 行为 |
|------|----------|-----------------------------|
| `@NetApi(...)` | 抽象类 | client→clientKey, responseType, executeWrapper, unwrapSuccess |
| `@Get(path)` / `@Post(path)` / `@Put(path)` / `@Delete(path)` | 方法 | url=baseUrl+path, method, 可选 contentType |
| `@DataPath(path)` | 方法 | parser 从 response.data[path] 取数据 |
| `@Body()` | 方法参数 | body |
| `@Part(name)` | 方法参数 | multipart/form-data 单字段/文件，与 contentType: formData 配合，生成器拼成 FormData |
| `@Query()` | 方法参数 | queryParameters |
| `@QueryKey(name)` | 方法参数 | queryParameters[name] |
| `@Header(name)` | 方法参数 | headers[name] |
| `@Path(name)` | 方法参数 | path 中 {name} 替换为参数值 |
| `@StreamResponse()` | 方法 | 后端返回流：生成器调 [NetRequest.requestStreamResponse]，再按返回类型/约定返回 stream |
| `RequestOptions?`（类型） | 方法最后可选参数 | 传入 .execute(options: options) |

---

## 二、各类注解说明与生成器行为

### 1. 类级注解

#### `@NetApi({ client, responseType, executeWrapper, unwrapSuccess })`

- **作用对象**：抽象类。
- **含义**：标记为 Net 接口，由生成器为该类生成实现（如 `_XxxServerImpl`）。
- **参数建议**：

| 参数 | 类型 | 含义 | 默认值 |
|------|------|------|--------|
| `client` | `String?` | 发起请求的类名 | `'NetRequest'` |
| `responseType` | `String?` | 统一响应类型 | `'BaseResponse'` |
| `executeWrapper` | `String?` | 执行包装（loading/异常），如 `RequestHelper.execute`；空则不包装 | `'RequestHelper.execute'` |
| `unwrapSuccess` | `bool` | 成功时只返回 `data`（true）还是整份 response（false） | `true` |

- **生成器**：扫描带 `@NetApi` 的抽象类，收集带 `@Get`/`@Post`/`@Put`/`@Delete` 的抽象方法并生成实现。

---

### 2. HTTP 方法注解

#### `@Get(path)` / `@Post(path)` / `@Put(path)` / `@Delete(path)`  

- **作用对象**：抽象方法。
- **含义**：声明 HTTP 方法与相对路径；`path` 为字符串，可与 baseUrl 拼接。
- **生成器**：根据注解生成 `method: HttpMethod.get/post/put/delete` 与 `url`。

**建议**：四者保持同一风格，仅 method 不同；若后续支持 path 占位符，可与 `@Path` 配合。

---

### 3. 参数注解（请求体与 Query）

#### `@Body()`

- **作用对象**：方法参数（通常一个），对应 Retrofit @Body。
- **含义**：该参数作为请求体；生成代码使用 `body: param.toJson()`（有 `toJson`）或 `body: param`（如 `Map`）。
- **生成器**：将对应参数写入 `requestHttp(..., body: ...)`。

#### `@Part(name)`（表单 / 文件上传）

- **作用对象**：方法参数，对应 Retrofit @Part。
- **含义**：multipart/form-data 的一个字段或文件。方法上需配合 `@Post(path, contentType: ContentType.formData)`（或 Put 等）。生成器收集所有 `@Part` 参数，构建 `FormData` 作为 body；若参数类型为 `File`，生成器应转为 `MultipartFile` 再填入 FormData。
- **替代写法**：不用 `@Part` 时，可单参数 `@Body()` 类型为 `Map<String, dynamic>` 或 `FormData`，由调用方自行组装（Map 中文件值需为 `MultipartFile`）。

#### `@Query()`

- **作用对象**：方法参数。
- **含义**：该参数作为 Query 整体（如 `Map<String, dynamic>`），生成代码合并到 `queryParameters`。
- **生成器**：GET 等请求将 Map 展开为 query 或传入 dio 的 query 参数。

#### `@QueryKey(name)`（可选，当前包已存在）

- **作用对象**：方法参数。
- **含义**：单个参数对应 query 的一个 key，如 `@QueryKey('user_id') String userId` → `queryParameters['user_id'] = userId`。
- **生成器**：适合多命名参数映射到不同 query key，与 `@Query()` 二选一或组合使用。

---

### 4. 响应解析相关注解

#### `@DataPath('archive')`

- **作用对象**：方法。
- **含义**：从 `response.data['archive']` 解析返回模型，而不是直接用 `response.data`。
- **生成器**：解析时使用 `response.data?[path]` 再传入 `T.fromJson`。

**返回类型**：指定什么就接什么。返回 `Future<bool?>` 时生成器只判断 `response?.isSuccess`，不解析 data；无需单独注解。

#### `@StreamResponse()`（后端返回流）

- **作用对象**：方法。
- **含义**：该方法对应后端流式响应（SSE/Stream）。生成器应调用 [NetRequest.requestStreamResponse]（透传 cancelToken 等），再**按返回类型或约定**返回 stream，例如返回 `Future<Stream<String>>` 时用 [SseStreamParser.parse] 或 utf8.decoder + LineSplitter，返回 `Future<Stream<List<int>>>` 时直接返回 response.data?.stream。
- **生成器**：方法需同时标注 HTTP 方法（如 @Get）与 @StreamResponse；生成实现中先 await requestStreamResponse，再按约定拼流。调用方负责消费 stream 与 cancelToken 取消。

---

### 5. 可选扩展注解（建议）

#### `@Header(name)` / `@Headers(Map?)`

- **作用对象**：方法或参数。
- **含义**：为单次请求添加自定义请求头。
- **生成器**：在 `requestHttp` 或 dio 的 `options.headers` 中注入对应 key-value。

#### `@Path('id')`

- **作用对象**：方法参数。
- **含义**：path 中的占位符，如 `@Get('/user/{id}')` 与 `@Path('id') int id`，生成代码将 `{id}` 替换为参数值。
- **生成器**：在拼接 `url` 时做字符串替换或 path 模板解析。

---

## 三、方法签名约定（与设计文档一致）

- **返回 `Future<T?>` 且 T 有 `fromJson`**：生成 `parser: (json) => T.fromJson(json)`，成功时返回 `T?`。
- **返回 `Future<bool?>`**：仅判断 `response?.isSuccess`，返回 `bool?`（指定什么就接什么）。
- **最后一个可选参数 `RequestOptions? options`**：传入生成的 `.execute(options: options)`（当配置了 `executeWrapper` 时）。

---

## 四、建议实现的优先级

1. **必须（与设计文档一致，对齐 Retrofit）**  
   `@NetApi`、`@Get`/`@Post`/`@Put`/`@Delete`、`@Body`、`@Query`、`@DataPath`；返回类型决定解析方式（指定什么就接什么）。

2. **已有实现可保留**  
   `@QueryKey`（多命名 query 参数映射）。

3. **可选扩展**  
   `@Header`/`@Headers`、`@Path`（path 占位符），按业务需要再增加。

---

## 五、包内现状与文档对应关系

- **net_retrofit_kit** 中已定义：`NetApi`、`Get`/`Post`/`Put`/`Delete`、`Body`、`Query`、`QueryKey`、`DataPath`，与设计文档及本文「必须」项一致；请求层使用 `queryParameters` / `body`（对齐 Retrofit），无 `parameter` / `isQueryParameters`。
- 生成器需实现：扫描 `@NetApi` 类、根据方法注解与参数注解生成 `url`、`queryParameters`、`body`、`parser`、`execute` 包装，输出如 `_XxxServerImpl` 的实现类。

本文档仅给出**注解设计与建议**，具体生成逻辑见 [net_kit_retrofit_style.md](../../docs/net_kit_retrofit_style.md) 的「生成器需要做的事」一节。

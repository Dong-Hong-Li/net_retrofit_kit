// 根据 lib/src/generate/annotations.dart 与 INetClient.requestHttp 契约生成。
// 生成器根据本配置为每个带 @Get/@Post/@Put/@Delete 的抽象方法生成实现代码。

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:net_retrofit_kit/src/network/http_method.dart';
import 'package:net_retrofit_kit/src/network/net_content_type.dart';
import 'package:source_gen/source_gen.dart';

/// 单个方法的生成配置，与 [annotations.dart] 及 [INetClient.requestHttp] 一一对应。
///
/// 生成器根据 [path]、[pathParams]、baseUrl 拼 [url]；根据 [method] 填 HttpMethod；
/// [queryParam]/[queryKeyParams] → queryParameters；[bodyParam]/[partParams] → body；
/// [headerParams] → headers；[contentType]、[clientKey]、[parserConfig]、[stream] 对应 requestHttp 其余参数。
class MethodGeneratorConfig {
  const MethodGeneratorConfig({
    required this.path,
    required this.method,
    this.contentType,
    this.clientKey,
    required this.stream,
    this.queryParam,
    this.queryKeyParams = const {},
    this.bodyParam,
    this.partParams = const {},
    this.headerParams = const {},
    this.pathParams = const {},
    required this.parserConfig,
  });

  // ========================== 来自 @Get/@Post/@Put/@Delete（HttpMethodAnnotation） ==========================

  /// 相对路径，与 baseUrl 拼接得到 [url]；可含占位符，如 `/user/{id}`，由 [pathParams] 替换。
  final String path;

  /// 请求方法，对应 [HttpMethod]。
  final HttpMethod method;

  /// 请求 Content-Type，对应 [HttpMethodAnnotation.contentType]；null 表示默认 [ContentType.json]。
  final ContentType? contentType;

  // ========================== 来自 @NetApi ==========================

  /// 对应 [NetApi.client]，即 requestHttp 的 [clientKey]；null 时生成代码不传 clientKey，由 [NetRequest.defaultKey] 规则解析。
  final String? clientKey;

  // ========================== 来自 @StreamResponse ==========================

  /// 是否为流式请求；true 时生成器应调用 [NetRequest.requestStreamResponse] 并按返回类型生成 stream 处理。
  final bool stream;

  // ========================== 来自 @Query / @QueryKey ==========================

  /// 作为 query 整体的参数名（[Query]）；存在时 requestHttp 的 queryParameters 直接为该参数。
  final String? queryParam;

  /// Query 单 key 与参数名映射（[QueryKey(name)] → 方法参数名），合并进 queryParameters。
  final Map<String, String> queryKeyParams;

  // ========================== 来自 @Body / @Part ==========================

  /// 作为请求体的参数名（[Body]）；formData 时与 [partParams] 二选一或组合由生成器约定。
  final String? bodyParam;

  /// Part 名称与参数名映射（[Part(name)] → 方法参数名），用于 multipart/form-data。
  final Map<String, String> partParams;

  // ========================== 来自 @Header / @Path ==========================

  /// Header 名称与参数名映射（[Header(name)] → 方法参数名）。
  final Map<String, String> headerParams;

  /// Path 占位符名称与参数名映射（path 中 {name} → 方法参数名）。
  final Map<String, String> pathParams;

  // ========================== 解析器（返回类型 + @DataPath + NetApi.responseType/unwrapSuccess） ==========================

  /// 解析相关配置，用于生成 [DataParser] 或流式解析代码。
  final ParserGeneratorConfig parserConfig;

  static const _httpMethodNames = {'Get', 'Post', 'Put', 'Delete'};

  /// 用 [InterfaceType].element.name 与 typeArguments 拼接类型名，避免 [getDisplayString] 在尖括号旁插入空格。
  static String _returnTypeNameFromType(DartType type) {
    DartType t = type;
    if (t is InterfaceType) {
      final it = t;
      final name = it.element.name ?? '';
      if ((name == 'Future' || name == 'Stream') &&
          it.typeArguments.length == 1) {
        return _returnTypeNameFromType(it.typeArguments.first);
      }
      if (it.typeArguments.isEmpty) return name;
      final args = it.typeArguments.map(_returnTypeNameFromType).join(', ');
      return '$name<$args>';
    }
    return t.getDisplayString();
  }

  /// 从方法及其类上的 [NetApi] 注解生成 [MethodGeneratorConfig]。
  factory MethodGeneratorConfig.generateMethodGeneratorConfig(
    MethodElement method,
    ConstantReader netApiAnnotation,
  ) {
    final responseTypeName =
        netApiAnnotation.peek('responseType')?.stringValue ?? 'BaseResponse';
    final unwrapSuccess =
        netApiAnnotation.peek('unwrapSuccess')?.boolValue ?? true;
    final clientKey = netApiAnnotation.peek('client')?.stringValue;
    final effectiveClientKey =
        (clientKey != null && clientKey.isNotEmpty) ? clientKey : null;

    String path = '';
    HttpMethod httpMethod = HttpMethod.get;
    ContentType? contentType;
    bool stream = false;
    String? dataPath;

    for (final ann in method.metadata.annotations) {
      final name = ann.element?.enclosingElement?.name;
      if (name == null) continue;
      final obj = ann.computeConstantValue();
      if (obj == null) continue;
      final reader = ConstantReader(obj);
      if (_httpMethodNames.contains(name)) {
        path = reader.peek('path')?.stringValue ?? '';
        final ct = reader.peek('contentType');
        if (ct != null && !ct.isNull && ct.isInt) {
          final idx = ct.intValue;
          if (idx >= 0 && idx < ContentType.values.length) {
            contentType = ContentType.values[idx];
          }
        }
        switch (name) {
          case 'Get':
            httpMethod = HttpMethod.get;
            break;
          case 'Post':
            httpMethod = HttpMethod.post;
            break;
          case 'Put':
            httpMethod = HttpMethod.put;
            break;
          case 'Delete':
            httpMethod = HttpMethod.delete;
            break;
        }
      } else if (name == 'StreamResponse') {
        stream = true;
      } else if (name == 'DataPath') {
        dataPath = reader.peek('path')?.stringValue;
      }
    }

    Map<String, String> queryKeyParams = {};
    Map<String, String> partParams = {};
    Map<String, String> headerParams = {};
    Map<String, String> pathParams = {};
    String? queryParam;
    String? bodyParam;

    for (final p in method.formalParameters) {
      for (final ann in p.metadata.annotations) {
        final n = ann.element?.enclosingElement?.name;
        if (n == null) continue;
        final obj = ann.computeConstantValue();
        if (obj == null) continue;
        final reader = ConstantReader(obj);
        final paramName = p.name ?? p.displayName;
        switch (n) {
          case 'Query':
            queryParam = paramName;
            break;
          case 'QueryKey':
            final key = reader.peek('name')?.stringValue;
            if (key != null) queryKeyParams[key] = paramName;
            break;
          case 'Body':
            bodyParam = paramName;
            break;
          case 'Part':
            final partName = reader.peek('name')?.stringValue;
            if (partName != null) partParams[partName] = paramName;
            break;
          case 'Header':
            final headerName = reader.peek('name')?.stringValue;
            if (headerName != null) headerParams[headerName] = paramName;
            break;
          case 'Path':
            final pathName = reader.peek('name')?.stringValue;
            if (pathName != null) pathParams[pathName] = paramName;
            break;
        }
      }
    }

    final returnTypeName = _returnTypeNameFromType(method.returnType);

    return MethodGeneratorConfig(
      path: path,
      method: httpMethod,
      contentType: contentType,
      clientKey: effectiveClientKey,
      stream: stream,
      queryParam: queryParam,
      queryKeyParams: queryKeyParams,
      bodyParam: bodyParam,
      partParams: partParams,
      headerParams: headerParams,
      pathParams: pathParams,
      parserConfig: ParserGeneratorConfig(
        responseTypeName: responseTypeName,
        unwrapSuccess: unwrapSuccess,
        dataPath: dataPath,
        returnTypeName: returnTypeName,
      ),
    );
  }
}

/// 解析器生成配置，对应 [NetApi.responseType]/[unwrapSuccess]、方法上的 [DataPath]、方法返回类型。
class ParserGeneratorConfig {
  const ParserGeneratorConfig({
    required this.responseTypeName,
    required this.unwrapSuccess,
    this.dataPath,
    required this.returnTypeName,
  });

  /// 统一响应类型名，如 [NetApi.responseType] 的 `BaseResponse`。
  final String responseTypeName;

  /// 成功时是否只返回 data（[NetApi.unwrapSuccess]）。
  final bool unwrapSuccess;

  /// 从 response.data[path] 解析，对应 [DataPath.path]；null 表示用 response.data。
  final String? dataPath;

  /// 方法返回的类型名（如 Future 的 UserModel），用于生成 fromJson/T 解析。
  final String returnTypeName;
}

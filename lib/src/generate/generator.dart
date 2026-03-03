import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:net_retrofit_kit/src/generate/annotations.dart';
import 'package:net_retrofit_kit/src/generate/method_generator_config.dart';
import 'package:source_gen/source_gen.dart';

/// @Get / @Post / @Put / @Delete 的类名，用于判断方法是否带 HTTP 方法注解
const _httpMethodNames = {'Get', 'Post', 'Put', 'Delete'};

/// 判断方法是否带有 @Get / @Post / @Put / @Delete 注解
bool _hasHttpMethodAnnotation(MethodElement method) {
  for (final a in method.metadata.annotations) {
    final name = a.element?.enclosingElement?.name;
    if (name != null && _httpMethodNames.contains(name)) return true;
  }
  return false;
}

class NetRetrofitGenerator extends GeneratorForAnnotation<NetApi> {
  @override
  Iterable<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement || !element.isAbstract) {
      throw InvalidGenerationSourceError(
        '`@NetApi()` 只能用于抽象类',
        element: element,
      );
    }

    final classElement = element;

    // 只处理「抽象方法且带 @Get / @Post / @Put / @Delete」的方法
    final abstractMethodsWithConfig = classElement.methods
        .where((MethodElement m) => m.isAbstract && _hasHttpMethodAnnotation(m))
        .map((MethodElement m) => (
              m,
              MethodGeneratorConfig.generateMethodGeneratorConfig(m, annotation)
            ))
        .toList();

    if (abstractMethodsWithConfig.isEmpty) {
      return ['// No abstract HTTP methods to implement'];
    }

    final buffer = StringBuffer();
    buffer.writeln(
        'class ${classElement.name}Impl implements ${classElement.name} {');
    for (final (method, config) in abstractMethodsWithConfig) {
      buffer.write(_generateMethodImplementation(method, config));
    }
    buffer.write('}');
    return [buffer.toString()];
  }

  /// 生成方法签名的参数部分（不含括号）
  String _methodParameters(MethodElement method) {
    final requiredPos = <String>[];
    final optionalPos = <String>[];
    final named = <String>[];
    for (final p in method.formalParameters) {
      final typeStr = p.type.getDisplayString();
      final nameStr = p.name ?? p.displayName;
      final param = '$typeStr $nameStr';
      if (p.isNamed) {
        named.add(p.isRequiredNamed ? 'required $param' : param);
      } else if (p.isOptionalPositional) {
        optionalPos.add(param);
      } else {
        requiredPos.add(param);
      }
    }
    final parts = <String>[];
    if (requiredPos.isNotEmpty) parts.add(requiredPos.join(', '));
    if (optionalPos.isNotEmpty) parts.add('[${optionalPos.join(', ')}]');
    if (named.isNotEmpty) parts.add('{${named.join(', ')}}');
    return parts.join(', ');
  }

  /// 生成 url 表达式：baseUrl + path，path 中 {name} 替换为对应参数
  String _buildUrl(MethodGeneratorConfig config) {
    String pathStr = config.path;
    for (final entry in config.pathParams.entries) {
      pathStr = pathStr.replaceAll('{${entry.key}}', '\$${entry.value}');
    }
    return "url: '\${NetRequest.options.baseUrl}$pathStr'";
  }

  /// 生成 queryParameters 表达式
  String? _buildQueryParameters(MethodGeneratorConfig config) {
    if (config.queryParam != null) {
      return 'queryParameters: ${config.queryParam}';
    }
    if (config.queryKeyParams.isNotEmpty) {
      final entries = config.queryKeyParams.entries
          .map((e) => "'${e.key}': ${e.value}")
          .join(', ');
      return 'queryParameters: {$entries}';
    }
    return null;
  }

  /// 生成 body 表达式（含 @Body 或 @Part FormData）
  String? _buildBody(MethodElement method, MethodGeneratorConfig config) {
    if (config.bodyParam != null) {
      return 'body: ${config.bodyParam}';
    }
    if (config.partParams.isNotEmpty) {
      final entries = config.partParams.entries.map((e) {
        final paramName = e.value;
        final isFile = method.formalParameters
            .where((p) => (p.name ?? p.displayName) == paramName)
            .any((p) => p.type.getDisplayString().contains('File'));
        final value =
            isFile ? 'MultipartFile.fromFileSync($paramName.path)' : paramName;
        return "'${e.key}': $value";
      }).join(', ');
      return 'body: FormData.fromMap({$entries})';
    }
    return null;
  }

  /// 生成 headers 表达式
  String? _buildHeaders(MethodGeneratorConfig config) {
    if (config.headerParams.isEmpty) return null;
    final entries = config.headerParams.entries
        .map((e) => "'${e.key}': ${e.value}")
        .join(', ');
    return 'headers: {$entries}';
  }

  /// 生成 contentType 表达式（仅当非默认时）
  String? _buildContentType(MethodGeneratorConfig config) {
    if (config.contentType == null) return null;
    return 'contentType: ContentType.${config.contentType!.name}';
  }

  /// 生成 clientKey 表达式；null 时不传，由 NetRequest.defaultKey 规则解析。
  String? _buildClientKey(MethodGeneratorConfig config) {
    if (config.clientKey == null) return null;
    return "clientKey: '${config.clientKey}'";
  }

  /// 是否包含 CancelToken? cancelToken 参数
  bool _hasCancelTokenParameter(MethodElement method) {
    return method.formalParameters.any((p) =>
        (p.name ?? p.displayName) == 'cancelToken' &&
        p.type.getDisplayString().contains('CancelToken'));
  }

  /// 生成 parser 表达式（根据返回类型：fromJson 或 as 强转；@DataPath 时从 json[path] 解析）
  String _buildParser(MethodGeneratorConfig config) {
    final T = config.parserConfig.returnTypeName;
    final dataPath = config.parserConfig.dataPath;
    const primitives = {'bool', 'int', 'double', 'String', 'num'};
    final isPrimitive =
        primitives.contains(T) || T.startsWith('Map<') || T.startsWith('List<');
    if (dataPath != null) {
      if (isPrimitive) {
        return 'parser: (json) => (json as Map<String, dynamic>)["$dataPath"] as $T';
      }
      return 'parser: (json) => $T.fromJson((json as Map<String, dynamic>)["$dataPath"] as Map<String, dynamic>)';
    }
    if (isPrimitive) {
      return 'parser: (json) => json as $T';
    }
    return 'parser: (json) => $T.fromJson(json as Map<String, dynamic>)';
  }

  /// 获取 requestHttp 的泛型 T（Future<> 中的 T） 即返回类型
  String _responseTypeArgument(MethodElement method) {
    final rt = method.returnType;
    if (rt is InterfaceType && rt.typeArguments.isNotEmpty) {
      return rt.typeArguments.first.getDisplayString();
    }
    return rt.getDisplayString();
  }

  /// 返回类型是否为非空基本类型
  bool _isNonNullablePrimitive(String typeArg) {
    return typeArg == 'bool' ||
        typeArg == 'int' ||
        typeArg == 'double' ||
        typeArg == 'String' ||
        typeArg == 'num';
  }

  /// 非空基本类型的默认值，用于 response.data ?? default。
  String _defaultValueForPrimitive(String typeArg) {
    switch (typeArg) {
      case 'bool':
        return 'false';
      case 'int':
      case 'num':
        return '0';
      case 'double':
        return '0.0';
      case 'String':
        return "''";
      default:
        return 'null';
    }
  }

  /// 生成 return response.data 或 response.data ?? default（非空基本类型时）。
  String _buildReturnData(String typeArg) {
    if (_isNonNullablePrimitive(typeArg)) {
      final defaultVal = _defaultValueForPrimitive(typeArg);
      return 'return response.data ?? $defaultVal;';
    }
    return 'return response.data;';
  }

  /// 生成方法的实现代码
  String _generateMethodImplementation(
      MethodElement method, MethodGeneratorConfig config) {
    final returnTypeStr = method.returnType.getDisplayString();
    final paramsStr = _methodParameters(method);
    final typeArg = _responseTypeArgument(method);

    if (config.stream) {
      return _generateStreamMethod(
          method, config, returnTypeStr, paramsStr, typeArg);
    }

    final buffer = StringBuffer();
    buffer.writeln('  @override');
    buffer.writeln('  $returnTypeStr ${method.name}($paramsStr) async {');
    buffer.writeln(
        '    final response = await NetRequest.requestHttp<$typeArg>(');
    buffer.writeln('      ${_buildUrl(config)},');
    buffer.writeln('      method: ${config.method},');
    final q = _buildQueryParameters(config);
    if (q != null) buffer.writeln('      $q,');
    final body = _buildBody(method, config);
    if (body != null) buffer.writeln('      $body,');
    final headers = _buildHeaders(config);
    if (headers != null) buffer.writeln('      $headers,');
    final contentType = _buildContentType(config);
    if (contentType != null) buffer.writeln('      $contentType,');
    final clientKey = _buildClientKey(config);
    if (clientKey != null) buffer.writeln('      $clientKey,');
    if (_hasCancelTokenParameter(method)) {
      buffer.writeln('      cancelToken: cancelToken,');
    }
    buffer.writeln('      ${_buildParser(config)},');
    buffer.writeln('    );');
    buffer.writeln('    ${_buildReturnData(typeArg)}');
    buffer.writeln('  }');
    return buffer.toString();
  }

  /// 生成流式响应方法的实现
  String _generateStreamMethod(
      MethodElement method,
      MethodGeneratorConfig config,
      String returnTypeStr,
      String paramsStr,
      String typeArg) {
    final buffer = StringBuffer();
    buffer.writeln('  @override');
    buffer.writeln('  $returnTypeStr ${method.name}($paramsStr) async {');
    buffer.writeln(
        '    final response = await NetRequest.requestStreamResponse(');
    buffer.writeln('      ${_buildUrl(config)},');
    buffer.writeln('      method: ${config.method},');
    final q = _buildQueryParameters(config);
    if (q != null) buffer.writeln('      $q,');
    final clientKey = _buildClientKey(config);
    if (clientKey != null) buffer.writeln('      $clientKey,');
    if (_hasCancelTokenParameter(method)) {
      buffer.writeln('      cancelToken: cancelToken,');
    }
    buffer.writeln('    );');
    buffer.writeln('    final stream = response.data?.stream;');
    buffer.writeln('    if (stream == null) return Stream.empty();');
    buffer.writeln(
        '    return stream.transform(utf8.decoder).transform(const LineSplitter());');
    buffer.writeln('  }');
    return buffer.toString();
  }
}

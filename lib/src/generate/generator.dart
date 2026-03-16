import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:net_retrofit_kit/src/generate/annotations.dart';
import 'package:net_retrofit_kit/src/generate/method_generator_config.dart';
import 'package:net_retrofit_kit/src/generate/parser_expression.dart';
import 'package:source_gen/source_gen.dart';

/// Names of @Get/@Post/@Put/@Delete annotations for HTTP-method detection.
const _httpMethodNames = {'Get', 'Post', 'Put', 'Delete'};

/// Whether the method has any HTTP method annotation.
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
        '`@NetApi()` can only be used on abstract classes',
        element: element,
      );
    }

    final classElement = element;

    // Only process abstract methods annotated with an HTTP method.
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

  /// Builds parameter declarations for method signature (without parentheses).
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

  /// Builds url expression: `baseUrl + path`, replacing `{name}` placeholders.
  String _buildUrl(MethodGeneratorConfig config) {
    String pathStr = config.path;
    for (final entry in config.pathParams.entries) {
      pathStr = pathStr.replaceAll('{${entry.key}}', '\$${entry.value}');
    }
    return "url: '\${NetRequest.options.baseUrl}$pathStr'";
  }

  /// Builds queryParameters expression.
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

  /// Builds body expression (@Body or @Part FormData).
  /// Contract: @Body can be a class model. If param type is not Map, generated
  /// code uses `param.toJson()` or `param?.toJson()` when param is nullable.
  String? _buildBody(MethodElement method, MethodGeneratorConfig config) {
    if (config.bodyParam != null) {
      final paramName = config.bodyParam!;
      DartType? bodyParamType;
      for (final p in method.formalParameters) {
        if ((p.name ?? p.displayName) == paramName) {
          bodyParamType = p.type;
          break;
        }
      }
      final isMapType = bodyParamType != null &&
          bodyParamType is InterfaceType &&
          bodyParamType.element.name == 'Map';
      final isNullable = bodyParamType != null &&
          bodyParamType.getDisplayString().endsWith('?');
      final String bodyValue;
      if (isMapType) {
        bodyValue = paramName;
      } else {
        bodyValue = isNullable ? '$paramName?.toJson()' : '$paramName.toJson()';
      }
      return 'body: $bodyValue';
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

  /// Builds headers expression.
  String? _buildHeaders(MethodGeneratorConfig config) {
    if (config.headerParams.isEmpty) return null;
    final entries = config.headerParams.entries
        .map((e) => "'${e.key}': ${e.value}")
        .join(', ');
    return 'headers: {$entries}';
  }

  /// Builds contentType expression (only when non-default).
  String? _buildContentType(MethodGeneratorConfig config) {
    if (config.contentType == null) return null;
    return 'contentType: ContentType.${config.contentType!.name}';
  }

  /// Builds clientKey expression. If null, it is omitted and resolved by
  /// NetRequest.defaultKey rules.
  String? _buildClientKey(MethodGeneratorConfig config) {
    if (config.clientKey == null) return null;
    return "clientKey: '${config.clientKey}'";
  }

  /// Whether method includes `CancelToken? cancelToken` parameter.
  bool _hasCancelTokenParameter(MethodElement method) {
    return method.formalParameters.any((p) =>
        (p.name ?? p.displayName) == 'cancelToken' &&
        p.type.getDisplayString().contains('CancelToken'));
  }

  /// Builds parser expression from return type
  /// (fromJson or `as` cast; with @DataPath uses `json[path]`).
  String _buildParser(MethodGeneratorConfig config) {
    return buildParserExpression(
      config.parserConfig.returnTypeName,
      config.parserConfig.dataPath,
    );
  }

  /// Gets generic T for requestHttp (the inner type of Future<> return type).
  String _responseTypeArgument(MethodElement method) {
    final rt = method.returnType;
    if (rt is InterfaceType && rt.typeArguments.isNotEmpty) {
      return rt.typeArguments.first.getDisplayString();
    }
    return rt.getDisplayString();
  }

  /// Builds `return response.data;` statement.
  String _buildReturnData(String typeArg) {
    return 'return response.data;';
  }

  /// Generates method implementation code.
  String _generateMethodImplementation(
      MethodElement method, MethodGeneratorConfig config) {
    final returnTypeStr = method.returnType.getDisplayString();
    final paramsStr = _methodParameters(method);
    // Non-stream: keep request type aligned with parser using
    // parserConfig.returnTypeName to avoid generic spacing issues from
    // getDisplayString().
    final typeArg = config.stream
        ? _responseTypeArgument(method)
        : config.parserConfig.returnTypeName;

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

  /// Generates stream-response method implementation.
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

// 无外部依赖，供生成器与测试使用。

bool _hasSpaceAroundAngleBrackets(String s) {
  return s.contains(' <') || s.contains('< ') ||
      s.contains(' >') || s.contains('> ');
}

/// 根据返回类型名和 dataPath 生成 parser 表达式。
/// 类型名通常由 [InterfaceType].element.name + typeArguments 拼接（无空格）；若含空格则加括号避免被解析成比较运算。
String buildParserExpression(String returnTypeName, String? dataPath) {
  const primitives = {'bool', 'int', 'double', 'String', 'num'};
  final isPrimitive = primitives.contains(returnTypeName) ||
      returnTypeName.startsWith('Map<') ||
      returnTypeName.startsWith('List<');
  final typeForFromJson = returnTypeName.contains('<') &&
          _hasSpaceAroundAngleBrackets(returnTypeName)
      ? '($returnTypeName)'
      : returnTypeName;
  if (dataPath != null) {
    if (isPrimitive) {
      return 'parser: (json) => (json as Map<String, dynamic>)["$dataPath"] as $returnTypeName';
    }
    return 'parser: (json) => $typeForFromJson.fromJson((json as Map<String, dynamic>)["$dataPath"] as Map<String, dynamic>)';
  }
  if (isPrimitive) {
    return 'parser: (json) => json as $returnTypeName';
  }
  return 'parser: (json) => $typeForFromJson.fromJson(json as Map<String, dynamic>)';
}

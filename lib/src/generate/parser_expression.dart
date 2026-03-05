// 无外部依赖，供生成器与测试使用。

/// 根据返回类型名和 dataPath 生成 parser 表达式。
/// 泛型类型名（含 `<`）会用括号包裹，避免 [getDisplayString] 可能产生的空格导致
/// `Response < String >.fromJson` 被解析成比较运算。
String buildParserExpression(String returnTypeName, String? dataPath) {
  const primitives = {'bool', 'int', 'double', 'String', 'num'};
  final isPrimitive = primitives.contains(returnTypeName) ||
      returnTypeName.startsWith('Map<') ||
      returnTypeName.startsWith('List<');
  final typeForFromJson =
      returnTypeName.contains('<') ? '($returnTypeName)' : returnTypeName;
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

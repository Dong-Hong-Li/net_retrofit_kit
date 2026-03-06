// No external dependencies. Used by both generator and tests.

bool _hasSpaceAroundAngleBrackets(String s) {
  return s.contains(' <') || s.contains('< ') ||
      s.contains(' >') || s.contains('> ');
}

/// Builds a parser expression from return type name and optional dataPath.
/// Type names are usually built from [InterfaceType].element.name plus
/// typeArguments (without spaces). If spaces exist around angle brackets,
/// parentheses are added to avoid parse ambiguity.
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

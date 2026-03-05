// 无外部依赖，供生成器与测试使用。

/// 从 `Future<T>` / `Future<Stream<T>>` 等显示字符串中提取 T 的简短名称。
/// 仅当末尾的 `>` 是外层 Future/Stream 的闭合括号时才去掉（即 `>` 个数多于 `<` 时），
/// 避免 analyzer 返回 `Future<Response < String>` 时误删泛型闭合导致得到 `Response < String`。
String stripReturnTypeName(String display) {
  String s = display;
  if (s.endsWith('?')) s = s.substring(0, s.length - 1);
  for (final prefix in ['Future<', 'Stream<']) {
    if (s.startsWith(prefix)) {
      s = s.substring(prefix.length);
      final openCount = '<'.allMatches(s).length;
      final closeCount = '>'.allMatches(s).length;
      if (closeCount > openCount && s.endsWith('>')) {
        s = s.substring(0, s.length - 1);
      }
    }
  }
  if (s.endsWith('?')) s = s.substring(0, s.length - 1);
  return s;
}

// No external dependencies. Used by both generator and tests.

/// Extracts the inner type name T from display strings like `Future<T>` or
/// `Future<Stream<T>>`.
/// It only strips a trailing `>` when that bracket belongs to the outer
/// Future/Stream wrapper (`>` count is greater than `<` count), so we do not
/// accidentally remove generic closing brackets from analyzer outputs like
/// `Future<Response < String>`.
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

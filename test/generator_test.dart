import 'package:flutter_test/flutter_test.dart';
import 'package:net_retrofit_kit/src/generate/parser_expression.dart';

void main() {
  group('buildParserExpression', () {
    test('泛型类型名带尖括号时用括号包裹，避免被解析成比较运算', () {
      // 正常无空格
      final a = buildParserExpression('Response<String>', null);
      expect(a, contains('(Response<String>).fromJson'));
      expect(a, isNot(contains('Response < String')));

      // 模拟 getDisplayString() 可能产生的带空格形式
      final b = buildParserExpression('Response < String >', null);
      expect(b, contains('(Response < String >).fromJson'));
      expect(b, isNot(contains('Response < String >.fromJson'))); // 不能是未加括号的
    });

    test('非泛型类型名不加括号', () {
      final a = buildParserExpression('UserModel', null);
      expect(
          a,
          equals(
              'parser: (json) => UserModel.fromJson(json as Map<String, dynamic>)'));
      expect(a, isNot(contains('(UserModel)')));

      final b = buildParserExpression('DemoModel', null);
      expect(b, contains('DemoModel.fromJson'));
    });

    test('基本类型走 as 强转，不调用 fromJson', () {
      expect(
        buildParserExpression('String', null),
        equals('parser: (json) => json as String'),
      );
      expect(
        buildParserExpression('int', null),
        equals('parser: (json) => json as int'),
      );
      expect(
        buildParserExpression('bool', null),
        equals('parser: (json) => json as bool'),
      );
    });

    test('有 dataPath 时从 json[path] 解析，泛型仍加括号', () {
      final a = buildParserExpression('Response<String>', 'data');
      expect(a, contains('(Response<String>).fromJson'));
      expect(a, contains('["data"]'));

      final b = buildParserExpression('Response < String >', 'result');
      expect(b, contains('(Response < String >).fromJson'));
      expect(b, contains('["result"]'));
    });

    test('Map/List 视为非 fromJson 类型', () {
      final a = buildParserExpression('Map<String, dynamic>', null);
      expect(a, equals('parser: (json) => json as Map<String, dynamic>'));
      final b = buildParserExpression('List<int>', null);
      expect(b, equals('parser: (json) => json as List<int>'));
    });
  });
}

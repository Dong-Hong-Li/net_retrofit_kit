import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:net_retrofit_kit/src/generate/parser_expression.dart';
import 'package:net_retrofit_kit/src/generate/return_type_name.dart';

void main() {
  group('stripReturnTypeName', () {
    test('Future<Response<String>> extracts to Response<String>', () {
      expect(
        stripReturnTypeName('Future<Response<String>>'),
        equals('Response<String>'),
      );
    });

    test('keeps generic closing when analyzer returns single >', () {
      // Simulate getDisplayString output: Future<Response < String> with one >.
      expect(
        stripReturnTypeName('Future<Response < String>'),
        equals('Response < String>'),
      );
    });

    test('extracts correctly when double > has spaces', () {
      expect(
        stripReturnTypeName('Future<Response < String >>'),
        equals('Response < String >'),
      );
    });

    test('removes nullable suffix ?', () {
      expect(
        stripReturnTypeName('Future<Response<String>>?'),
        equals('Response<String>'),
      );
    });

    test('returns non-Future input as-is', () {
      expect(
          stripReturnTypeName('Response<String>'), equals('Response<String>'));
    });
  });

  group('buildParserExpression', () {
    test('no-space generic uses TypeName.fromJson; spaced generic is wrapped', () {
      final a = buildParserExpression('Response<String>', null);
      expect(a, contains('Response<String>.fromJson'));
      expect(a, isNot(contains('(Response<String>)')));

      final b = buildParserExpression('Response < String >', null);
      expect(b, contains('(Response < String >).fromJson'));
      expect(b, isNot(contains('Response < String >.fromJson')));
    });

    test('non-generic type names are not wrapped', () {
      final a = buildParserExpression('UserModel', null);
      expect(
          a,
          equals(
              'parser: (json) => UserModel.fromJson(json as Map<String, dynamic>)'));
      expect(a, isNot(contains('(UserModel)')));

      final b = buildParserExpression('DemoModel', null);
      expect(b, contains('DemoModel.fromJson'));
    });

    test('primitives use as-cast and do not call fromJson', () {
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

    test('parses from json[path] when dataPath is provided', () {
      final a = buildParserExpression('Response<String>', 'data');
      expect(a, contains('Response<String>.fromJson'));
      expect(a, contains('["data"]'));

      final b = buildParserExpression('Response < String >', 'result');
      expect(b, contains('(Response < String >).fromJson'));
      expect(b, contains('["result"]'));
    });

    test('Map/List are treated as non-fromJson types', () {
      final a = buildParserExpression('Map<String, dynamic>', null);
      expect(a, equals('parser: (json) => json as Map<String, dynamic>'));
      final b = buildParserExpression('List<int>', null);
      expect(b, equals('parser: (json) => json as List<int>'));
    });
  });

  group('generic return type generation consistency', () {
    test('requestHttp generic and parser type stay consistent without spaces', () {
      final path = 'example/lib/server/response_type_api.g.dart';
      final file = File(path);
      if (!file.existsSync()) {
        return; // Skip when not generated.
      }
      final content = file.readAsStringSync();
      // Generator should use parserConfig.returnTypeName to stay consistent
      // with parser and avoid spacing injected by getDisplayString.
      expect(content, contains('requestHttp<String>'));
      expect(content, isNot(contains('Response < String >')));
    });
  });
}

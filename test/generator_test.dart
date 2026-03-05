import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:net_retrofit_kit/src/generate/parser_expression.dart';
import 'package:net_retrofit_kit/src/generate/return_type_name.dart';

void main() {
  group('stripReturnTypeName', () {
    test('Future<Response<String>> 提取为 Response<String>', () {
      expect(
        stripReturnTypeName('Future<Response<String>>'),
        equals('Response<String>'),
      );
    });

    test('analyzer 返回单 > 时保留泛型闭合，不误删', () {
      // 模拟 getDisplayString 返回 Future<Response < String>（仅一个闭合 >）
      expect(
        stripReturnTypeName('Future<Response < String>'),
        equals('Response < String>'),
      );
    });

    test('带空格的双 > 提取正确', () {
      expect(
        stripReturnTypeName('Future<Response < String >>'),
        equals('Response < String >'),
      );
    });

    test('可空类型去掉 ?', () {
      expect(
        stripReturnTypeName('Future<Response<String>>?'),
        equals('Response<String>'),
      );
    });

    test('非 Future 原样返回', () {
      expect(
          stripReturnTypeName('Response<String>'), equals('Response<String>'));
    });
  });

  group('buildParserExpression', () {
    test('无空格泛型直接 TypeName.fromJson，带空格泛型才加括号', () {
      final a = buildParserExpression('Response<String>', null);
      expect(a, contains('Response<String>.fromJson'));
      expect(a, isNot(contains('(Response<String>)')));

      final b = buildParserExpression('Response < String >', null);
      expect(b, contains('(Response < String >).fromJson'));
      expect(b, isNot(contains('Response < String >.fromJson')));
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

    test('有 dataPath 时从 json[path] 解析', () {
      final a = buildParserExpression('Response<String>', 'data');
      expect(a, contains('Response<String>.fromJson'));
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

  group('泛型返回类型生成一致性', () {
    test('response_type_api.g.dart 中 requestHttp 泛型与 parser 类型一致（无空格）', () {
      final path = 'example/lib/server/response_type_api.g.dart';
      final file = File(path);
      if (!file.existsSync()) {
        return; // 未生成时跳过
      }
      final content = file.readAsStringSync();
      // 生成器应使用 parserConfig.returnTypeName，与 parser 一致，避免 getDisplayString 插入空格
      expect(content, contains('requestHttp<String>'));
      expect(content, isNot(contains('Response < String >')));
    });
  });
}

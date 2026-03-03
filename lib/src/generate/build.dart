import 'package:build/build.dart';
import 'package:net_retrofit_kit/src/generate/generator.dart';
import 'package:source_gen/source_gen.dart';

/// 根据配置创建构建器
Builder netRetrofitBuilder(BuilderOptions options) {
  return SharedPartBuilder([
    NetRetrofitGenerator(),
  ], 'net_retrofit_kit');
}

import 'package:build/build.dart';
import 'package:net_retrofit_kit/src/generate/generator.dart';
import 'package:source_gen/source_gen.dart';

/// Creates the builder from the given options.
Builder netRetrofitBuilder(BuilderOptions options) {
  return SharedPartBuilder([
    NetRetrofitGenerator(),
  ], 'net_retrofit_kit');
}

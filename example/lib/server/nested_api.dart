// Example 5: @DataPath — parse from response.data[path] instead of response.data.

import 'package:net_retrofit_kit/net_retrofit_kit.dart';

import 'nested_model.dart';

part 'nested_api.g.dart';

/// Demonstrates @DataPath: when backend returns { data: { result: { value: "x" } } }, parse from data.result.
@NetApi()
abstract class NestedApi {
  @Get('/get')
  @DataPath('result')
  Future<NestedModel?> getNested();
}

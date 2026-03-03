// 案例5：@DataPath — 从 response.data[path] 解析，而非 response.data。

import 'package:net_retrofit_kit/net_retrofit_kit.dart';

import 'nested_model.dart';

part 'nested_api.g.dart';

/// 演示 @DataPath：后端返回 { data: { result: { value: "x" } } } 时，从 data.result 解析。
@NetApi()
abstract class NestedApi {
  @Get('/get')
  @DataPath('result')
  Future<NestedModel?> getNested();
}

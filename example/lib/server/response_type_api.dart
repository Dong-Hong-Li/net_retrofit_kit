// 案例：泛型返回类型 Future<Response<String>>，验证生成 parser 为 (Response<String>).fromJson 或 (Response < String >).fromJson。

import 'package:net_retrofit_kit/net_retrofit_kit.dart';

part 'response_type_api.g.dart';

@NetApi()
abstract class ResponseTypeApi {
  @Get('/api/example')
  Future<String> getExample();

  @Post('/api/example')
  Future<String> postExample();
}

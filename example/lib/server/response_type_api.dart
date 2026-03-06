// Example: generic return type Future<Response<String>>; verifies generated parser uses (Response<String>).fromJson.

import 'package:net_retrofit_kit/net_retrofit_kit.dart';

part 'response_type_api.g.dart';

@NetApi()
abstract class ResponseTypeApi {
  @Get('/api/example')
  Future<String> getExample();

  @Post('/api/example')
  Future<String> postExample();
}

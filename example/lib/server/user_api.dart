// 案例2：@Get + @QueryKey、@Path、@Header。

import 'package:net_retrofit_kit/net_retrofit_kit.dart';

import 'user_model.dart';

part 'user_api.g.dart';

/// 演示 @QueryKey、@Path、@Header 的 GET 接口。
@NetApi()
abstract class UserApi {
  /// GET /user?page=1&size=10
  @Get('/get')
  Future<UserModel?> getList(
    @QueryKey('page') int page,
    @QueryKey('size') int size,
  );

  /// GET /anything/{id}，路径占位符。
  @Get('/anything/{id}')
  Future<UserModel?> getById(@Path('id') String id);

  /// 带自定义 Header 的请求。
  @Get('/get')
  Future<UserModel?> getWithAuth(@Header('Authorization') String token);

  /// @Query() 整体传 Map。
  @Get('/get')
  Future<UserModel?> getByQuery(@Query() Map<String, dynamic> query);
}

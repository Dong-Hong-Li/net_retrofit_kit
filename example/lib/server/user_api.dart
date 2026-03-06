// Example 2: @Get + @QueryKey, @Path, @Header.

import 'package:net_retrofit_kit/net_retrofit_kit.dart';

import 'user_model.dart';

part 'user_api.g.dart';

/// Demonstrates GET with @QueryKey, @Path, @Header.
@NetApi()
abstract class UserApi {
  /// GET /user?page=1&size=10
  @Get('/get')
  Future<UserModel?> getList(
    @QueryKey('page') int page,
    @QueryKey('size') int size,
  );

  /// GET /anything/{id} — path placeholder.
  @Get('/anything/{id}')
  Future<UserModel?> getById(@Path('id') String id);

  /// Request with custom Header.
  @Get('/get')
  Future<UserModel?> getWithAuth(@Header('Authorization') String token);

  /// @Query() passes the full Map.
  @Get('/get')
  Future<UserModel?> getByQuery(@Query() Map<String, dynamic> query);
}

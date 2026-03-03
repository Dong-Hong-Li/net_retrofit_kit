// 案例3：@Post @Body、@Put、@Delete + @Path。

import 'package:net_retrofit_kit/net_retrofit_kit.dart';

import 'article_model.dart';

part 'article_api.g.dart';

/// 演示 POST/PUT/DELETE 与 @Body、路径占位符。
@NetApi()
abstract class ArticleApi {
  @Post('/post')
  Future<ArticleModel?> create(@Body() Map<String, dynamic> body);

  @Put('/put')
  Future<ArticleModel?> update(@Body() Map<String, dynamic> body);

  @Delete('/anything/{id}')
  Future<bool> delete(@Path('id') String id);
}

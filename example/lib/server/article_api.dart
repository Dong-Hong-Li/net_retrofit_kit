// Example 3: @Post @Body, @Put, @Delete + @Path; @Body supports Map or class model (must implement toJson).

import 'package:net_retrofit_kit/net_retrofit_kit.dart';

import 'article_model.dart';

part 'article_api.g.dart';

/// Demonstrates POST/PUT/DELETE with @Body and path placeholders.
/// @Body() can be Map or class model; for non-Map types the generator emits body.toJson(), so the model must implement toJson.
@NetApi()
abstract class ArticleApi {
  @Post('/post')
  Future<ArticleModel?> create(@Body() Map<String, dynamic> body);

  /// Uses a class model as Body; generated code calls body.toJson().
  @Post('/post')
  Future<ArticleModel?> createWithModel(@Body() CreateArticleRequest body);

  @Put('/put')
  Future<ArticleModel?> update(@Body() Map<String, dynamic> body);

  /// Uses a class model as Body; generated code calls body.toJson().
  @Put('/put')
  Future<ArticleModel?> updateWithModel(@Body() UpdateArticleRequest body);

  @Delete('/anything/{id}')
  Future<bool> delete(@Path('id') String id);
}

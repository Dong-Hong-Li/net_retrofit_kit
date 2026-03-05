// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article_api.dart';

// **************************************************************************
// NetRetrofitGenerator
// **************************************************************************

class ArticleApiImpl implements ArticleApi {
  @override
  Future<ArticleModel?> create(Map<String, dynamic> body) async {
    final response = await NetRequest.requestHttp<ArticleModel>(
      url: '${NetRequest.options.baseUrl}/post',
      method: HttpMethod.post,
      body: body,
      parser: (json) => ArticleModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  @override
  Future<ArticleModel?> update(Map<String, dynamic> body) async {
    final response = await NetRequest.requestHttp<ArticleModel>(
      url: '${NetRequest.options.baseUrl}/put',
      method: HttpMethod.put,
      body: body,
      parser: (json) => ArticleModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  @override
  Future<bool> delete(String id) async {
    final response = await NetRequest.requestHttp<bool>(
      url: '${NetRequest.options.baseUrl}/anything/$id',
      method: HttpMethod.delete,
      parser: (json) => json as bool,
    );
    return response.data ?? false;
  }
}

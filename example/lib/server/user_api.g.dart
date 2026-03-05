// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_api.dart';

// **************************************************************************
// NetRetrofitGenerator
// **************************************************************************

class UserApiImpl implements UserApi {
  @override
  Future<UserModel?> getList(int page, int size) async {
    final response = await NetRequest.requestHttp<UserModel>(
      url: '${NetRequest.options.baseUrl}/get',
      method: HttpMethod.get,
      queryParameters: {'page': page, 'size': size},
      parser: (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  @override
  Future<UserModel?> getById(String id) async {
    final response = await NetRequest.requestHttp<UserModel>(
      url: '${NetRequest.options.baseUrl}/anything/$id',
      method: HttpMethod.get,
      parser: (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  @override
  Future<UserModel?> getWithAuth(String token) async {
    final response = await NetRequest.requestHttp<UserModel>(
      url: '${NetRequest.options.baseUrl}/get',
      method: HttpMethod.get,
      headers: {'Authorization': token},
      parser: (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  @override
  Future<UserModel?> getByQuery(Map<String, dynamic> query) async {
    final response = await NetRequest.requestHttp<UserModel>(
      url: '${NetRequest.options.baseUrl}/get',
      method: HttpMethod.get,
      queryParameters: query,
      parser: (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }
}

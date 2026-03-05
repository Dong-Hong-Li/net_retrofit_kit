// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'response_type_api.dart';

// **************************************************************************
// NetRetrofitGenerator
// **************************************************************************

class ResponseTypeApiImpl implements ResponseTypeApi {
  @override
  Future<String> getExample() async {
    final response = await NetRequest.requestHttp<String>(
      url: '${NetRequest.options.baseUrl}/api/example',
      method: HttpMethod.get,
      parser: (json) => json as String,
    );
    return response.data ?? '';
  }

  @override
  Future<String> postExample() async {
    final response = await NetRequest.requestHttp<String>(
      url: '${NetRequest.options.baseUrl}/api/example',
      method: HttpMethod.post,
      parser: (json) => json as String,
    );
    return response.data ?? '';
  }
}

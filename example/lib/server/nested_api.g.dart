// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nested_api.dart';

// **************************************************************************
// NetRetrofitGenerator
// **************************************************************************

class NestedApiImpl implements NestedApi {
  @override
  Future<NestedModel?> getNested() async {
    final response = await NetRequest.requestHttp<NestedModel?>(
      url: '${NetRequest.options.baseUrl}/get',
      method: HttpMethod.get,
      parser: (json) => NestedModel.fromJson(
          (json as Map<String, dynamic>)["result"] as Map<String, dynamic>),
    );
    return response.data;
  }
}

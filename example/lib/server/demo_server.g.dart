// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'demo_server.dart';

// **************************************************************************
// NetRetrofitGenerator
// **************************************************************************

class DemoServerImpl implements DemoServer {
  @override
  Future<DemoModel?> login(Map<String, dynamic> body) async {
    final response = await NetRequest.requestHttp<DemoModel?>(
      url: '${NetRequest.options.baseUrl}/post',
      method: HttpMethod.post,
      body: body,
      parser: (json) => DemoModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  @override
  Future<DemoModel?> getUserInfo() async {
    final response = await NetRequest.requestHttp<DemoModel?>(
      url: '${NetRequest.options.baseUrl}/get',
      method: HttpMethod.get,
      parser: (json) => DemoModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  @override
  Future<DemoModel?> googleLogin(Map<String, dynamic> body) async {
    final response = await NetRequest.requestHttp<DemoModel?>(
      url: '${NetRequest.options.baseUrl}/post',
      method: HttpMethod.post,
      body: body,
      parser: (json) => DemoModel.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  @override
  Future<bool> saveArchives(Map<String, dynamic> body) async {
    final response = await NetRequest.requestHttp<bool>(
      url: '${NetRequest.options.baseUrl}/post',
      method: HttpMethod.post,
      body: body,
      parser: (json) => json as bool,
    );
    return response.data ?? false;
  }

  @override
  Future<Stream<String>> getStreamLines({CancelToken? cancelToken}) async {
    final response = await NetRequest.requestStreamResponse(
      url: '${NetRequest.options.baseUrl}/stream/3',
      method: HttpMethod.get,
      cancelToken: cancelToken,
    );
    final stream = response.data?.stream;
    if (stream == null) return Stream.empty();
    return stream.transform(utf8.decoder).transform(const LineSplitter());
  }
}

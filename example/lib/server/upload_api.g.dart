// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_api.dart';

// **************************************************************************
// NetRetrofitGenerator
// **************************************************************************

class UploadApiImpl implements UploadApi {
  @override
  Future<Map<String, dynamic>?> upload(File file, String name) async {
    final response = await NetRequest.requestHttp<Map<String, dynamic>>(
      url: '${NetRequest.options.baseUrl}/post',
      method: HttpMethod.post,
      body: FormData.fromMap(
          {'file': MultipartFile.fromFileSync(file.path), 'name': name}),
      clientKey: 'upload',
      parser: (json) => json as Map<String, dynamic>,
    );
    return response.data;
  }
}

// Example 4: multipart/form-data, @Post(contentType: ContentType.formData) + @Part.

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:net_retrofit_kit/net_retrofit_kit.dart';

part 'upload_api.g.dart';

/// Demonstrates file upload: FormData + @Part; uses a dedicated Client (see main: NetRequest.setClient('upload', ...)).
@NetApi(client: 'upload')
abstract class UploadApi {
  @Post('/post', contentType: ContentType.formData)
  Future<Map<String, dynamic>?> upload(
    @Part('file') File file,
    @Part('name') String name,
  );
}

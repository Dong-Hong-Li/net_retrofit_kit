// 案例4：multipart/form-data，@Post(contentType: ContentType.formData) + @Part。

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:net_retrofit_kit/net_retrofit_kit.dart';

part 'upload_api.g.dart';

/// 演示文件上传：FormData + @Part。
@NetApi()
abstract class UploadApi {
  @Post('/post', contentType: ContentType.formData)
  Future<Map<String, dynamic>?> upload(
    @Part('file') File file,
    @Part('name') String name,
  );
}

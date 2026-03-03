/// 请求体 / Content-Type。
enum ContentType {
  json,
  formData,
  xWwwFormUrlencoded;

  String toStringType() {
    switch (this) {
      case ContentType.json:
        return 'application/json';
      case ContentType.formData:
        return 'multipart/form-data';
      case ContentType.xWwwFormUrlencoded:
        return 'application/x-www-form-urlencoded';
    }
  }
}

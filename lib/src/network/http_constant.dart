typedef DataParser<T> = T Function(Object? json);

/// 统一业务响应体。成功约定：HTTP 200 且 [code] == [BusinessCode.success]（0）时 [isSuccess] 为 true；
/// 否则视为业务拒绝，[NetRequest.requestHttp] 会直接抛 [ApiError.businessReject]。
class BaseResponse<T> {
  final int code;
  final String msg;
  final T data;
  final int total;

  BaseResponse({
    required this.code,
    required this.msg,
    required this.data,
    this.total = 0,
  });

  /// 是否业务成功：code == [BusinessCode.success]
  bool get isSuccess => code == BusinessCode.success;

  /// 由业务层自行解析。msg 兼容后端字段 [msg] 或 [message]；data 为 null 时不调用 [dataParser]。
  factory BaseResponse.fromJson(Map<String, dynamic> json,
      {DataParser<T>? dataParser}) {
    final rawData = json['data'];
    T? data;
    if (dataParser != null) {
      if (rawData == null) {
        data = null;
      } else {
        try {
          data = dataParser(rawData);
        } catch (e, _) {
          throw ArgumentError(
            'BaseResponse.fromJson dataParser 解析失败: $e',
            'data',
          );
        }
      }
    } else {
      data = rawData as T?;
    }

    final msgValue = json['msg'] ?? json['message'] ?? '';
    return BaseResponse(
      code: (json['code'] is int)
          ? json['code'] as int
          : (json['code'] is num)
              ? (json['code'] as num).toInt()
              : -1,
      msg: msgValue is String ? msgValue : msgValue.toString(),
      data: data as T,
      total: (json['total'] is int)
          ? json['total'] as int
          : (json['total'] is num)
              ? (json['total'] as num).toInt()
              : 0,
    );
  }
}

class BaseResponseData<T> {
  final T data;
  final int total;

  BaseResponseData({required this.data, required this.total});
}

class HttpConstant {
  static const String data = 'data';
  static const String message = 'msg';
  static const String code = 'code';
  static const String success = 'succ';
}

/// 业务层成功码：与后端约定 code == 0 表示成功，与 HTTP 状态码区分。
class BusinessCode {
  static const int success = 0;
}

/// HTTP 状态码（与业务 code 区分）
class ExceptionHandle {
  static const int success = 200;
  static const int unauthorized = 401;
}

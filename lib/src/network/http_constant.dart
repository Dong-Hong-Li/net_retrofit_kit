typedef DataParser<T> = T Function(Object? json);

/// Unified business response wrapper.
/// Success is defined as HTTP 200 and [code] == [BusinessCode.success] (0),
/// in which case [isSuccess] is true; otherwise it is treated as business
/// rejection and [NetRequest.requestHttp] throws [ApiError.businessReject].
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

  /// Whether business-layer status is successful: code == [BusinessCode.success].
  bool get isSuccess => code == BusinessCode.success;

  /// Parsed by business-layer rules. `msg` is compatible with backend fields
  /// [msg] and [message]. [dataParser] is not called when data is null.
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
            'BaseResponse.fromJson dataParser parse failed: $e',
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

/// Business-layer success code agreed with backend: code == 0.
class BusinessCode {
  static const int success = 0;
}

/// HTTP status codes (separate from business code).
class ExceptionHandle {
  static const int success = 200;
  static const int unauthorized = 401;
}

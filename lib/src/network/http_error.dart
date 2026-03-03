import 'package:dio/dio.dart';

/// 错误类型：统一用这一套，不再使用 HttpError / NetRequestShoppingException / NetRequestShoppingRreject。
enum ApiErrorKind {
  /// 网络层异常（如 DioError、超时、断网）
  networkFailure,

  /// 业务拒绝：HTTP 200 但 code != BusinessCode.success
  businessReject,

  /// 请求被取消（如用户取消、页面 dispose 取消）
  cancelled,
}

/// 唯一对外使用的 API 错误类型。
/// 约定：成功 = HTTP 200 且业务 code == 0（BusinessCode.success）；其余为失败，用 [kind] 区分场景。
class ApiError implements Exception {
  final ApiErrorKind kind;
  final int? code;
  final String message;
  final dynamic data;
  final Exception? cause;

  ApiError({
    required this.kind,
    this.code,
    this.message = '',
    this.data,
    this.cause,
  });

  /// 从 Dio 异常构造（网络失败或取消）
  factory ApiError.fromDioError(DioError e) {
    final kind = e.type == DioErrorType.cancel
        ? ApiErrorKind.cancelled
        : ApiErrorKind.networkFailure;
    return ApiError(
      kind: kind,
      message: e.message ?? '',
      cause: e,
    );
  }

  /// 从业务响应构造（code != 0）
  factory ApiError.businessReject({
    required int code,
    String message = '',
    dynamic data,
  }) {
    return ApiError(
      kind: ApiErrorKind.businessReject,
      code: code,
      message: message,
      data: data,
    );
  }

  @override
  String toString() =>
      'ApiError(kind: $kind, code: $code, message: $message, data: $data)';
}

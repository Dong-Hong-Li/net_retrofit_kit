import 'package:dio/dio.dart';

/// Unified error categories used by the package.
enum ApiErrorKind {
  /// Transport/network failure (e.g. DioException, timeout, offline).
  networkFailure,

  /// Business rejection: HTTP 200 but code != BusinessCode.success.
  businessReject,

  /// Request cancelled (e.g. user cancellation or dispose-triggered cancel).
  cancelled,
}

/// Public API error type.
/// Success is defined as HTTP 200 and business code == 0
/// ([BusinessCode.success]); all other cases are failures distinguished by
/// [kind].
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

  /// Creates from Dio error (network failure or cancellation).
  factory ApiError.fromDioError(DioException e) {
    final kind = e.type == DioExceptionType.cancel
        ? ApiErrorKind.cancelled
        : ApiErrorKind.networkFailure;
    return ApiError(
      kind: kind,
      message: e.message ?? '',
      cause: e,
    );
  }

  /// Creates from a business-layer rejection response (code != 0).
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

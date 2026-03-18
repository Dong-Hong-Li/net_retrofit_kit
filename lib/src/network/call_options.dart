import 'package:dio/dio.dart';

/// Optional per-call options for generated API methods.
///
/// Prefer **optional positional** [CallOptions? options] so request-level options
/// are clearly not API parameters (which use named { }):
///   `void fn(必填, [CallOptions? options], {可选命名})`
/// When the method has other named params, Dart does not allow [ ] and { } in the
/// same method, so use named {CallOptions? options} there.
/// The generator forwards [cancelToken] and [clientKey] to the request layer.
///
/// Example (optional positional):
/// ```dart
/// @Get('/get')
/// Future<DemoModel?> getUserInfo([CallOptions? options]);
///
/// await api.getUserInfo();
/// await api.getUserInfo(CallOptions(cancelToken: token));
/// ```
class CallOptions {
  const CallOptions({
    this.cancelToken,
    this.clientKey,
  });

  /// Cancellation token for this request.
  final CancelToken? cancelToken;

  /// Override [NetRequest] client key for this request.
  final String? clientKey;
}

import 'package:dio/dio.dart';

/// 网络层配置，由业务方在启动时通过 [NetRequest.options] 传入。
///
/// [interceptors] 在 [NetRequest.createDio] 时按顺序添加到 Dio（在默认日志拦截器之后）。
class NetOptions {
  const NetOptions({
    required this.baseUrl,
    this.connectTimeout = const Duration(seconds: 60),
    this.receiveTimeout = const Duration(seconds: 60),
    this.sendTimeout = const Duration(seconds: 60),
    this.interceptors,
  });

  /// 基础 URL
  final String baseUrl;

  /// 连接超时时间
  final Duration connectTimeout;

  /// 接收超时时间
  final Duration receiveTimeout;

  /// 发送超时时间
  final Duration sendTimeout;

  /// 拦截器列表，与 Dio 的 [Interceptor] 一致；在默认日志拦截器之后按序添加。
  final List<Interceptor>? interceptors;
}

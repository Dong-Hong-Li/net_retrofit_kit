import 'package:dio/dio.dart';

/// 拦截器机制与 Dio 一致：使用 [Interceptor]（Dio 提供），在 [NetRequest] 创建或运行时注册。
///
/// **执行顺序**：请求时按添加顺序依次执行 [Interceptor.onRequest]；
/// 响应时按**添加的逆序**执行 [Interceptor.onResponse] / [Interceptor.onError]（栈式）。
///
/// **注册方式**：
/// 1. 初始化时通过 [NetOptions.interceptors] 传入，[NetRequest.createDio] 会在默认日志拦截器之后按序添加。
/// 2. 运行时通过 [NetRequest.addInterceptor] / [NetRequest.addInterceptors] 追加到当前 Dio 实例。
///
/// **示例**（鉴权、重试等）：
/// ```dart
/// NetRequest.options = NetOptions(
///   baseUrl: 'https://api.example.com',
///   interceptors: [
///     AuthInterceptor(),
///     RetryInterceptor(),
///   ],
/// );
/// // 或运行时追加
/// NetRequest.addInterceptor(MyInterceptor());
/// ```
///
/// 实现时继承 [Interceptor] 并重写 [Interceptor.onRequest]、[Interceptor.onResponse]、[Interceptor.onError]，
/// 在合适处调用 `handler.next(options|response|err)` 继续链。
typedef NetInterceptor = Interceptor;

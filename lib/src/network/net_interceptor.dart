import 'package:dio/dio.dart';

/// Interceptor mechanism aligned with Dio: use [Interceptor] (from Dio) and
/// register during [NetRequest] setup or runtime.
///
/// **Execution order**: requests run [Interceptor.onRequest] in insertion order;
/// responses/errors run [Interceptor.onResponse] / [Interceptor.onError] in
/// reverse insertion order (stack-like).
///
/// **Registration options**:
/// 1. Pass via [NetOptions.interceptors] during initialization; they are added
///    in order after the default logging interceptor by
///    [NetRequest.createDio].
/// 2. Append at runtime with [NetRequest.addInterceptor] /
///    [NetRequest.addInterceptors].
///
/// **Example** (auth, retry, etc.):
/// ```dart
/// NetRequest.options = NetOptions(
///   baseUrl: 'https://api.example.com',
///   interceptors: [
///     AuthInterceptor(),
///     RetryInterceptor(),
///   ],
/// );
/// // Or append at runtime
/// NetRequest.addInterceptor(MyInterceptor());
/// ```
///
/// Implement by extending [Interceptor] and overriding
/// [Interceptor.onRequest], [Interceptor.onResponse], and
/// [Interceptor.onError], then call `handler.next(options|response|err)` at
/// appropriate points to continue the chain.
typedef NetInterceptor = Interceptor;

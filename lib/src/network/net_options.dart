import 'package:dio/dio.dart';

/// Network-layer configuration injected at startup via [NetRequest.options].
///
/// [interceptors] are appended to Dio in [NetRequest.createDio] in order,
/// after the default logging interceptor.
class NetOptions {
  const NetOptions({
    required this.baseUrl,
    this.connectTimeout = const Duration(seconds: 60),
    this.receiveTimeout = const Duration(seconds: 60),
    this.sendTimeout = const Duration(seconds: 60),
    this.interceptors,
  });

  /// Base URL.
  final String baseUrl;

  /// Connection timeout.
  final Duration connectTimeout;

  /// Receive timeout.
  final Duration receiveTimeout;

  /// Send timeout.
  final Duration sendTimeout;

  /// Interceptor list compatible with Dio [Interceptor], appended in order
  /// after the default logging interceptor.
  final List<Interceptor>? interceptors;
}

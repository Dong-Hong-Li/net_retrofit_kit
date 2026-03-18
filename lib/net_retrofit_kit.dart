/// Retrofit-style networking annotations and codegen contract.
///
/// Usage:
/// 1. Configure [NetRequest.options] = [NetOptions](...) during startup.
/// 2. Annotate abstract classes with [NetApi] and methods with
///    [Get]/[Post]/[Put]/[Delete].
/// 3. Run build_runner to generate implementations (`*_impl.dart` or `.g.dart`).
/// 4. Generated code calls NetRequest, BaseResponse, and execute wrappers.
library;

export 'src/network/net_content_type.dart';
export 'src/network/http_constant.dart';
export 'src/network/http_error.dart';
export 'src/network/http_method.dart';
export 'src/network/inet_client.dart';
export 'src/network/istream_net_client.dart';
export 'src/network/call_options.dart';
export 'src/network/net_options.dart';
export 'src/network/net_request.dart';
export 'src/network/net_interceptor.dart';

//// ========================== Generator ==========================
export 'src/generate/annotations.dart';

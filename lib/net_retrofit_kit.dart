/// Retrofit 风格网络层注解与生成契约。
///
/// 使用方式：
/// 1. 启动时设置 [NetRequest.options] = [NetOptions](...) 传入配置
/// 2. 在抽象类上标注 [NetApi]，在方法上标注 [Get]/[Post]/[Put]/[Delete]
/// 3. 运行 build_runner 生成实现类（*_impl.dart 或 *.g.dart）
/// 4. 生成代码调用 NetRequest、BaseResponse、execute 包装
library;

export 'src/network/net_content_type.dart';
export 'src/network/http_constant.dart';
export 'src/network/http_error.dart';
export 'src/network/http_method.dart';
export 'src/network/inet_client.dart';
export 'src/network/net_options.dart';
export 'src/network/net_request.dart';
export 'src/network/net_interceptor.dart';
export 'src/network/default/default_net_client.dart';

//// ========================== 生成器相关 ==========================
export 'src/generate/annotations.dart';

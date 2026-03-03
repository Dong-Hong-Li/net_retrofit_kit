// 示例：手写抽象类 + 方法注解，运行 build_runner 生成 demo_server.g.dart。
// 实现类名为 DemoServerImpl，Repository 委托该实现体发请求。

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:net_retrofit_kit/net_retrofit_kit.dart';

import 'demo_model.dart';

part 'demo_server.g.dart';

/// 案例1：基础 API — @Get / @Post、@Body、流式 @StreamResponse。
@NetApi()
abstract class DemoServer {
  @Post('/post')
  Future<DemoModel?> login(@Body() Map<String, dynamic> body);

  @Get('/get')
  Future<DemoModel?> getUserInfo();

  @Post('/post')
  Future<DemoModel?> googleLogin(@Body() Map<String, dynamic> body);

  @Post('/post')
  Future<bool> saveArchives(@Body() Map<String, dynamic> body);

  @Get('/stream/3')
  @StreamResponse()
  Future<Stream<String>> getStreamLines({CancelToken? cancelToken});
}

/// 示例 Repository：委托 [DemoServerImpl] 发请求。
class DemoRepository {
  static DemoRepository get instance => DemoRepository._();

  DemoRepository._();
  final _mapper = DemoServerImpl();

  Future<DemoModel?> getUserInfo() async {
    try {
      return await _mapper.getUserInfo();
    } catch (e) {
      return null;
    }
  }

  Future<bool> saveArchives(Map<String, dynamic> body) async {
    try {
      return await _mapper.saveArchives(body);
    } catch (e) {
      return false;
    }
  }

  Future<bool> login(String mobile, String googleToken) async {
    try {
      await _mapper.login({'phone': mobile});
      await _mapper.googleLogin({'google_token': googleToken});
      return true;
    } catch (e) {
      return false;
    }
  }

  // 流式结果两种用法：① 等流全部再返回 List  ② 读一点反一点，每行回调
  /// 方式一：等流全部读完再返回。Page 只需 await 并展示 [result]。
  Future<List<String>> fetchStreamLines({CancelToken? cancelToken}) async {
    final stream = await _mapper.getStreamLines(cancelToken: cancelToken);
    final lines = <String>[];
    await for (final line in stream) {
      if (line.trim().isNotEmpty) lines.add(line);
    }
    return lines;
  }

  /// 方式二：读一点反一点，每收到一行就调 [onLine]。Page 可在回调里 setState 实时追加。
  Future<void> forEachStreamLine({
    CancelToken? cancelToken,
    required void Function(String line) onLine,
  }) async {
    final stream = await _mapper.getStreamLines(cancelToken: cancelToken);
    await for (final line in stream) {
      if (line.trim().isNotEmpty) onLine(line);
    }
  }
}

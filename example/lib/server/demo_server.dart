// Example: define abstract class + method annotations, run build_runner to generate demo_server.g.dart.
// Implementation class is DemoServerImpl; Repository delegates to it for requests.

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:net_retrofit_kit/net_retrofit_kit.dart';

import 'demo_model.dart';

part 'demo_server.g.dart';

/// Example 1: Basic API — @Get / @Post, @Body, streaming @StreamResponse.
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

/// Example Repository: delegates to [DemoServerImpl] for requests.
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

  // Two ways to consume stream: (1) collect all lines then return List; (2) callback per line.
  /// Option 1: wait for full stream then return. Page can await and display [result].
  Future<List<String>> fetchStreamLines({CancelToken? cancelToken}) async {
    final stream = await _mapper.getStreamLines(cancelToken: cancelToken);
    final lines = <String>[];
    await for (final line in stream) {
      if (line.trim().isNotEmpty) lines.add(line);
    }
    return lines;
  }

  /// Option 2: callback per line via [onLine]. Page can setState in the callback to append in real time.
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

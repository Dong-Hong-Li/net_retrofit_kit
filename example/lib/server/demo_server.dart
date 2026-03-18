// Example: define abstract class + method annotations, run build_runner to generate demo_server.g.dart.
// Implementation class is DemoServerImpl; Repository delegates to it for requests.

import 'dart:convert';
import 'package:net_retrofit_kit/net_retrofit_kit.dart';
import 'demo_model.dart';
part 'demo_server.g.dart';

/// Callback type for stream line consumption (avoids ambiguous ) in method signature).
typedef OnStreamLine = void Function(String line);

/// Example 1: Basic API — @Get / @Post, @Body, streaming @StreamResponse.
@NetApi()
abstract class DemoServer {
  @Post('/post')
  Future<DemoModel?> login(@Body() Map<String, dynamic> body,
      [CallOptions? options]);

  @Get('/get')
  Future<DemoModel?> getUserInfo([CallOptions? options]);

  @Post('/post')
  Future<DemoModel?> googleLogin(@Body() Map<String, dynamic> body,
      [CallOptions? options]);

  @Post('/post')
  Future<bool> saveArchives(@Body() Map<String, dynamic> body,
      [CallOptions? options]);

  @Get('/stream/3')
  @StreamResponse()
  Future<Stream<String>> getStreamLines([CallOptions? options]);
}

/// Example Repository: delegates to [DemoServerImpl] for requests.
class DemoRepository {
  static DemoRepository get instance => DemoRepository._();

  DemoRepository._();
  final _mapper = DemoServerImpl();

  Future<DemoModel?> getUserInfo([CallOptions? options]) async {
    try {
      return await _mapper.getUserInfo(options);
    } catch (e) {
      return null;
    }
  }

  Future<bool> saveArchives(Map<String, dynamic> body,
      [CallOptions? options]) async {
    try {
      return await _mapper.saveArchives(body, options);
    } catch (e) {
      return false;
    }
  }

  Future<bool> login(String mobile, String googleToken,
      [CallOptions? options]) async {
    try {
      await _mapper.login({'phone': mobile}, options);
      await _mapper.googleLogin({'google_token': googleToken}, options);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Two ways to consume stream: (1) collect all lines then return List; (2) callback per line.
  /// Option 1: wait for full stream then return. Page can await and display [result].
  Future<List<String>> fetchStreamLines([CallOptions? options]) async {
    final stream = await _mapper.getStreamLines(options);
    final lines = <String>[];
    await for (final line in stream) {
      if (line.trim().isNotEmpty) lines.add(line);
    }
    return lines;
  }

  /// Option 2: callback per line via [onLine]. Dart does not allow [optional positional] + {named} in one method, so options is named here.
  Future<void> forEachStreamLine(
      {CallOptions? options, required OnStreamLine onLine}) async {
    final stream = await _mapper.getStreamLines(options);
    await for (final line in stream) {
      if (line.trim().isNotEmpty) onLine(line);
    }
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:net_retrofit_kit_example/pages/stream_request_page.dart';
import 'package:net_retrofit_kit_example/server/article_api.dart';
import 'package:net_retrofit_kit_example/server/demo_server.dart';
import 'package:net_retrofit_kit_example/server/nested_api.dart';
import 'package:net_retrofit_kit_example/server/upload_api.dart';
import 'package:net_retrofit_kit_example/server/user_api.dart';

/// 全部案例入口：列出所有 API 示例并可直接发起请求。
class ExamplesListPage extends StatefulWidget {
  const ExamplesListPage({super.key});

  @override
  State<ExamplesListPage> createState() => _ExamplesListPageState();
}

class _ExamplesListPageState extends State<ExamplesListPage> {
  String? _result;
  bool _loading = false;
  final _demoApi = DemoServerImpl();
  final _userApi = UserApiImpl();
  final _articleApi = ArticleApiImpl();
  final _uploadApi = UploadApiImpl();
  final _nestedApi = NestedApiImpl();

  Future<void> _run(String title, Future<void> Function() fn) async {
    setState(() {
      _loading = true;
      _result = null;
    });
    try {
      await fn();
    } catch (e, st) {
      setState(() => _result = '错误: $e');
      debugPrintStack(stackTrace: st);
    } finally {
      setState(() => _loading = false);
    }
  }

  void _setResult(String s) {
    if (mounted) setState(() => _result = s);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('全部案例'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            '以下为生成器支持的全部注解组合示例，点击可发起请求（baseUrl: httpbin.org）',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          _card(
            title: '案例1：基础 API',
            subtitle: '@Get / @Post、@Body、@StreamResponse',
            children: [
              _btn(
                  'login(@Body)',
                  () => _run('login', () async {
                        await _demoApi.login({'phone': '13800138000'});
                        _setResult('login 请求已发送');
                      })),
              _btn(
                  'getUserInfo()',
                  () => _run('getUserInfo', () async {
                        final r = await _demoApi.getUserInfo();
                        _setResult(r != null
                            ? 'getUserInfo: ${r.mobile ?? r.userId}'
                            : 'null');
                      })),
              _btn(
                  'saveArchives(@Body)',
                  () => _run('saveArchives', () async {
                        final ok = await _demoApi.saveArchives({'key': 'demo'});
                        _setResult('saveArchives: $ok');
                      })),
              ListTile(
                title: const Text('流式 getStreamLines'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StreamRequestPage()),
                ),
              ),
            ],
          ),
          _card(
            title: '案例2：User API',
            subtitle: '@QueryKey、@Path、@Header、@Query()',
            children: [
              _btn(
                  'getList(page, size)',
                  () => _run('getList', () async {
                        final r = await _userApi.getList(1, 10);
                        _setResult(
                            r != null ? 'User: ${r.name ?? r.id}' : 'null');
                      })),
              _btn(
                  'getById(id)',
                  () => _run('getById', () async {
                        final r = await _userApi.getById('123');
                        _setResult(r != null ? 'User: ${r.name}' : 'null');
                      })),
              _btn(
                  'getWithAuth(token)',
                  () => _run('getWithAuth', () async {
                        final r = await _userApi.getWithAuth('Bearer x');
                        _setResult(r != null ? 'ok' : 'null');
                      })),
              _btn(
                  'getByQuery(Map)',
                  () => _run('getByQuery', () async {
                        final r =
                            await _userApi.getByQuery({'a': '1', 'b': '2'});
                        _setResult(r != null ? 'ok' : 'null');
                      })),
            ],
          ),
          _card(
            title: '案例3：Article API',
            subtitle: '@Post @Body、@Put、@Delete @Path',
            children: [
              _btn(
                  'create(@Body)',
                  () => _run('create', () async {
                        final r = await _articleApi
                            .create({'title': 't', 'content': 'c'});
                        _setResult(r != null ? 'Article: ${r.title}' : 'null');
                      })),
              _btn(
                  'update(@Body)',
                  () => _run('update', () async {
                        final r = await _articleApi
                            .update({'id': '1', 'title': 't2'});
                        _setResult(r != null ? 'ok' : 'null');
                      })),
              _btn(
                  'delete(id)',
                  () => _run('delete', () async {
                        final ok = await _articleApi.delete('1');
                        _setResult('delete: $ok');
                      })),
            ],
          ),
          _card(
            title: '案例4：Upload API（自定义 Client）',
            subtitle:
                '@NetApi(client: \'upload\')，自定义 UploadNetClient 实现 INetClient，main 中 setClient(\'upload\', UploadNetClient(dio))；ContentType.formData + @Part',
            children: [
              _btn(
                  'upload(file, name)',
                  () => _run('upload', () async {
                        final f = File(
                            '${Directory.systemTemp.path}/net_kit_demo_upload.txt');
                        f.writeAsStringSync('hello net_retrofit_kit');
                        try {
                          final r = await _uploadApi.upload(f, 'demo.txt');
                          _setResult(r != null ? 'upload 已发送' : 'null');
                        } finally {
                          f.deleteSync();
                        }
                      })),
            ],
          ),
          _card(
            title: '案例5：Nested API',
            subtitle: '@DataPath 从 data[path] 解析',
            children: [
              _btn(
                  'getNested()',
                  () => _run('getNested', () async {
                        final r = await _nestedApi.getNested();
                        _setResult(r != null ? 'Nested: ${r.value}' : 'null');
                      })),
            ],
          ),
          if (_result != null) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SelectableText(_result!,
                    style: const TextStyle(fontFamily: 'monospace')),
              ),
            ),
          ],
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _card({
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _btn(String label, VoidCallback onPressed) {
    return ListTile(
      title: Text(label),
      trailing: const Icon(Icons.play_arrow),
      onTap: _loading ? null : onPressed,
    );
  }
}

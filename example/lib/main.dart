import 'package:flutter/material.dart';
import 'package:net_retrofit_kit/net_retrofit_kit.dart';
import 'package:net_retrofit_kit_example/network/default_net_client.dart';
import 'package:net_retrofit_kit_example/network/upload_net_client.dart';
import 'package:net_retrofit_kit_example/server/demo_server.dart';
import 'package:net_retrofit_kit_example/pages/examples_list_page.dart';
import 'package:net_retrofit_kit_example/pages/stream_request_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Default client for business APIs (must be set before using NetRequest).
  NetRequest.options = const NetOptions(
    baseUrl: 'https://httpbin.org',
    connectTimeout: Duration(seconds: 15),
    receiveTimeout: Duration(seconds: 15),
    sendTimeout: Duration(seconds: 15),
  );
  NetRequest.setClient(
    NetRequest.defaultClientKey,
    DefaultNetClient(NetRequest.createDio(NetRequest.options)),
  );
  // Multi-client setup: register a dedicated upload client.
  final uploadDio = NetRequest.createDio(const NetOptions(
    baseUrl: 'https://httpbin.org',
    connectTimeout: Duration(seconds: 15),
    receiveTimeout: Duration(seconds: 60),
    sendTimeout: Duration(seconds: 60),
  ));
  NetRequest.setClient('upload', UploadNetClient(uploadDio));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'net_retrofit_kit Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _status =
      'Open "All examples" to explore scenarios, or use quick actions below.';
  bool _loading = false;
  final _repository = DemoRepository.instance;

  Future<void> _doLogin() async {
    setState(() {
      _loading = true;
      _status = 'Requesting... login(mobile)';
    });
    final result = await _repository.login('13800138000', 'demo_google_token');
    setState(() {
      _status = result ? 'Login succeeded' : 'Login failed';
    });
  }

  Future<void> _doGetUserInfo() async {
    setState(() {
      _loading = true;
      _status = 'Requesting... getUserInfo()';
    });
    try {
      final result = await _repository.getUserInfo();
      setState(() {
        _status = result != null
            ? 'User info: ${result.userId} / ${result.mobile} (DemoModel)'
            : 'getUserInfo returned null';
      });
    } catch (e, st) {
      setState(() => _status = 'Failed: $e');
      debugPrintStack(stackTrace: st);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _doSaveArchives() async {
    setState(() {
      _loading = true;
      _status = 'Requesting... saveArchives(body)';
    });
    try {
      final ok = await _repository.saveArchives({
        'key': 'net_retrofit_kit_example',
        'time': DateTime.now().toIso8601String(),
      });
      setState(() => _status =
          'saveArchives: ${ok == true ? "success" : "failed or false"}');
    } catch (e, st) {
      setState(() => _status = 'Failed: $e');
      debugPrintStack(stackTrace: st);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('net_retrofit_kit Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _status,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                FilledButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ExamplesListPage()),
                  ),
                  icon: const Icon(Icons.list),
                  label: const Text('All Examples'),
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: _loading ? null : _doLogin,
                  icon: const Icon(Icons.login),
                  label: const Text('login(mobile)'),
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: _loading ? null : _doGetUserInfo,
                  icon: const Icon(Icons.person),
                  label: const Text('getUserInfo()'),
                ),
                const SizedBox(height: 8),
                FilledButton.tonal(
                  onPressed: _loading ? null : _doLogin,
                  child: const Text('googleLogin(token)'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: _loading ? null : _doSaveArchives,
                  child: const Text('saveArchives(body)'),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const StreamRequestPage(),
                    ),
                  ),
                  icon: const Icon(Icons.stream),
                  label: const Text('Stream Request Example'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

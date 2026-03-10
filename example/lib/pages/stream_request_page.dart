// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:net_retrofit_kit_example/server/demo_server.dart';

/// Stream request demo: this page only awaits and displays final lines.
/// Stream consumption is handled in [DemoRepository.fetchStreamLines].
class StreamRequestPage extends StatefulWidget {
  const StreamRequestPage({super.key});

  @override
  State<StreamRequestPage> createState() => _StreamRequestPageState();
}

class _StreamRequestPageState extends State<StreamRequestPage> {
  List<String> _lines = [];
  bool _loading = false;
  String _error = '';
  CancelToken? _cancelToken;
  final _repository = DemoRepository.instance;

  Future<void> _startStream() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = '';
      _lines = ['Starting request...'];
    });
    _cancelToken = CancelToken();

    try {
      final result =
          await _repository.fetchStreamLines(cancelToken: _cancelToken);
      setState(() {
        _lines = ['Starting request...', ...result, '--- stream ended ---'];
        _loading = false;
      });
    } on DioError catch (e) {
      if (e.type == DioErrorType.cancel) {
        setState(() {
          _lines = [..._lines, 'Cancelled'];
          _loading = false;
        });
      } else {
        setState(() {
          _error = e.message ?? e.type.name;
          _loading = false;
        });
      }
    } catch (e, st) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
      debugPrintStack(stackTrace: st);
    }
  }

  void _cancelStream() {
    _cancelToken?.cancel('Cancelled by user');
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _cancelToken?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stream Request Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'The stream is consumed in DemoRepository.fetchStreamLines; this page only awaits and shows results.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                FilledButton.icon(
                  onPressed: _loading ? null : _startStream,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Stream Request'),
                ),
                const SizedBox(width: 8),
                if (_loading)
                  OutlinedButton.icon(
                    onPressed: _cancelStream,
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancel'),
                  ),
              ],
            ),
            if (_error.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                _error,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _lines.isEmpty
                    ? const Center(
                        child: Text(
                            'No data yet. Click the button above to start.'))
                    : ListView.builder(
                        itemCount: _lines.length,
                        itemBuilder: (_, i) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: SelectableText(
                            _lines[i],
                            style: const TextStyle(fontFamily: 'monospace'),
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../services/api_client.dart';
import '../../utils/json_utils.dart';

class OfflineSyncScreen extends StatefulWidget {
  const OfflineSyncScreen({super.key});

  @override
  State<OfflineSyncScreen> createState() => _OfflineSyncScreenState();
}

class _OfflineSyncScreenState extends State<OfflineSyncScreen> {
  bool _loading = false;
  String _message = 'Offline-ready structure is enabled. Pull downloads latest server data; push endpoint is ready for queued local changes.';

  Future<void> _pull() async {
    setState(() { _loading = true; _message = ''; });
    try {
      final res = await ApiClient.instance.get('/api/sync/pull');
      final data = JsonUtils.map(res['data']);
      setState(() => _message = 'Pulled: ${JsonUtils.list(data['customers']).length} customers, ${JsonUtils.list(data['products']).length} products, ${JsonUtils.list(data['suppliers']).length} suppliers.');
    } catch (e) {
      setState(() => _message = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pushTest() async {
    setState(() { _loading = true; _message = ''; });
    try {
      final res = await ApiClient.instance.post('/api/sync/push', {'changes': []});
      setState(() => _message = JsonUtils.str(res['message'], 'Sync push checked.'));
    } catch (e) {
      setState(() => _message = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Offline Sync')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Offline Mode & Sync', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  Text(_message, style: const TextStyle(color: Color(0xFF64748B))),
                  const SizedBox(height: 16),
                  if (_loading) const LinearProgressIndicator(),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(onPressed: _loading ? null : _pull, icon: const Icon(Icons.cloud_download_rounded), label: const Text('Pull latest data')),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(onPressed: _loading ? null : _pushTest, icon: const Icon(Icons.cloud_upload_rounded), label: const Text('Check push endpoint')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

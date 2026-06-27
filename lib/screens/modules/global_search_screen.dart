import 'package:flutter/material.dart';

import '../../services/api_client.dart';
import '../../utils/formatters.dart';
import '../../utils/json_utils.dart';

class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  final _controller = TextEditingController();
  bool _loading = false;
  String _error = '';
  List<Map<String, dynamic>> _rows = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final q = _controller.text.trim();
    if (q.length < 2) return;
    setState(() { _loading = true; _error = ''; });
    try {
      final res = await ApiClient.instance.get('/api/search', query: {'q': q});
      final data = JsonUtils.map(res['data']);
      final rows = <Map<String, dynamic>>[];
      for (final key in ['customers', 'suppliers', 'products', 'invoices']) {
        rows.addAll(JsonUtils.list(data[key]).map((e) => JsonUtils.map(e)));
      }
      setState(() => _rows = rows);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Global Search')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Search customer, supplier, product, invoice',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: IconButton(onPressed: _search, icon: const Icon(Icons.arrow_forward_rounded)),
            ),
            onSubmitted: (_) => _search(),
          ),
          const SizedBox(height: 12),
          if (_loading) const Center(child: CircularProgressIndicator()),
          if (_error.isNotEmpty) Text(_error, textAlign: TextAlign.center),
          if (!_loading && _error.isEmpty && _rows.isEmpty) const SizedBox(height: 220, child: Center(child: Text('Search anything in your business.'))),
          ..._rows.map((row) => Card(
            child: ListTile(
              leading: CircleAvatar(child: Text(JsonUtils.str(row['type'], '?').substring(0, 1).toUpperCase())),
              title: Text(JsonUtils.str(row['title'], '-'), style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Text(JsonUtils.str(row['subtitle'], '')),
              trailing: Text(row['amount'] == null ? '' : Formatters.amount(JsonUtils.number(row['amount']))),
            ),
          )),
        ],
      ),
    );
  }
}

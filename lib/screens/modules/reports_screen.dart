import 'package:flutter/material.dart';

import '../../services/api_client.dart';
import '../../utils/formatters.dart';
import '../../utils/json_utils.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  static const _reports = [
    _ReportItem('Profit / Loss', '/api/reports/profit-loss', Icons.insights_rounded),
    _ReportItem('Receivables', '/api/reports/receivables', Icons.account_balance_wallet_rounded),
    _ReportItem('Payables', '/api/reports/payables', Icons.payments_rounded),
    _ReportItem('Stock Report', '/api/reports/stock', Icons.inventory_rounded),
    _ReportItem('Audit Logs', '/api/reports/audit-logs', Icons.security_rounded),
    _ReportItem('Export Customers', '/api/export/customers', Icons.people_rounded),
    _ReportItem('Export Sales', '/api/export/sales', Icons.receipt_long_rounded),
    _ReportItem('Export Inventory', '/api/export/inventory', Icons.file_download_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports & Export')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: _reports.map((r) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Card(
            child: ListTile(
              leading: CircleAvatar(child: Icon(r.icon)),
              title: Text(r.title, style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: const Text('Open report from live API'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ReportResultScreen(item: r))),
            ),
          ),
        )).toList(),
      ),
    );
  }
}

class _ReportItem {
  final String title;
  final String endpoint;
  final IconData icon;
  const _ReportItem(this.title, this.endpoint, this.icon);
}

class ReportResultScreen extends StatefulWidget {
  final _ReportItem item;
  const ReportResultScreen({required this.item});

  @override
  State<ReportResultScreen> createState() => _ReportResultScreenState();
}

class _ReportResultScreenState extends State<ReportResultScreen> {
  bool _loading = true;
  String _error = '';
  dynamic _data;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = ''; });
    try {
      final res = await ApiClient.instance.get(widget.item.endpoint);
      setState(() => _data = res['data']);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rows = JsonUtils.list(_data).map((e) => JsonUtils.map(e)).toList();
    final obj = JsonUtils.map(_data);
    return Scaffold(
      appBar: AppBar(title: Text(widget.item.title)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(_error, textAlign: TextAlign.center))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (obj.isNotEmpty && rows.isEmpty)
                        ...obj.entries.map((e) => _ReportTile(label: e.key, value: _display(e.value)))
                      else if (rows.isEmpty)
                        const SizedBox(height: 220, child: Center(child: Text('No data found.')))
                      else
                        ...rows.map((row) => Card(
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: row.entries.take(8).map((e) => Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(width: 125, child: Text(e.key.replaceAll('_', ' '), style: const TextStyle(color: Color(0xFF64748B), fontSize: 12))),
                                    Expanded(child: Text(_display(e.value), style: const TextStyle(fontWeight: FontWeight.w700))),
                                  ],
                                ),
                              )).toList(),
                            ),
                          ),
                        )),
                    ],
                  ),
                ),
    );
  }

  String _display(dynamic value) {
    if (value == null) return '-';
    if (value is num) return Formatters.amount(value.toDouble());
    final text = value.toString();
    if (RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(text)) return Formatters.date(text);
    return text;
  }
}

class _ReportTile extends StatelessWidget {
  final String label;
  final String value;
  const _ReportTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(label.replaceAll('_', ' '), style: const TextStyle(fontWeight: FontWeight.w800)),
        trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
    );
  }
}

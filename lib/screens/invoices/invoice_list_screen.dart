import 'package:flutter/material.dart';

import '../../models/invoice.dart';
import '../../services/api_client.dart';
import '../../utils/formatters.dart';
import '../../utils/json_utils.dart';
import 'create_invoice_screen.dart';

class InvoiceListScreen extends StatefulWidget {
  const InvoiceListScreen({super.key});

  @override
  State<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends State<InvoiceListScreen> {
  bool _loading = true;
  String _error = '';
  List<SalesInvoice> _invoices = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final res = await ApiClient.instance.get('/api/sales-invoices', query: {'limit': 100});
      final rows = JsonUtils.list(res['data']);
      setState(() => _invoices = rows.map((e) => SalesInvoice.fromJson(JsonUtils.map(e))).toList());
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openCreate() async {
    final changed = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => const CreateInvoiceScreen()));
    if (changed == true) _load();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'PAID': return Colors.green;
      case 'PARTIAL': return Colors.orange;
      default: return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Scaffold(
      body: _error.isNotEmpty
          ? Center(child: Text(_error, textAlign: TextAlign.center))
          : RefreshIndicator(
              onRefresh: _load,
              child: _invoices.isEmpty
                  ? const Center(child: Text('No invoices yet. Tap + to create.'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (_, i) {
                        final inv = _invoices[i];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(backgroundColor: const Color(0xFF0F766E).withOpacity(0.10), child: const Icon(Icons.receipt_long_rounded, color: Color(0xFF0F766E))),
                            title: Text('${inv.invoiceNo} • ${inv.customerName}', style: const TextStyle(fontWeight: FontWeight.w800)),
                            subtitle: Text('${Formatters.date(inv.invoiceDate)} • Balance ${Formatters.amount(inv.balanceAmount)}'),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(Formatters.amount(inv.grandTotal), style: const TextStyle(fontWeight: FontWeight.w900)),
                                Text(inv.paymentStatus, style: TextStyle(color: _statusColor(inv.paymentStatus), fontSize: 12, fontWeight: FontWeight.w800)),
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemCount: _invoices.length,
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(onPressed: _openCreate, icon: const Icon(Icons.add), label: const Text('Invoice')),
    );
  }
}

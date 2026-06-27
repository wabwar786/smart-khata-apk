import 'package:flutter/material.dart';

import '../../models/payment.dart';
import '../../services/api_client.dart';
import '../../utils/formatters.dart';
import '../../utils/json_utils.dart';
import 'receive_payment_screen.dart';

class PaymentListScreen extends StatefulWidget {
  const PaymentListScreen({super.key});

  @override
  State<PaymentListScreen> createState() => _PaymentListScreenState();
}

class _PaymentListScreenState extends State<PaymentListScreen> {
  bool _loading = true;
  String _error = '';
  List<PaymentReceived> _payments = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = ''; });
    try {
      final res = await ApiClient.instance.get('/api/payments', query: {'limit': 100});
      final rows = JsonUtils.list(res['data']);
      setState(() => _payments = rows.map((e) => PaymentReceived.fromJson(JsonUtils.map(e))).toList());
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _receive() async {
    final changed = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => const ReceivePaymentScreen()));
    if (changed == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payments')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(_error, textAlign: TextAlign.center))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: _payments.isEmpty
                      ? const Center(child: Text('No payments yet.'))
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _payments.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (_, i) {
                            final p = _payments[i];
                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(backgroundColor: Colors.green.withOpacity(0.10), child: const Icon(Icons.payments_rounded, color: Colors.green)),
                                title: Text(p.customerName, style: const TextStyle(fontWeight: FontWeight.w800)),
                                subtitle: Text('${Formatters.date(p.paymentDate)} • ${p.paymentMethod}${p.description.isEmpty ? '' : ' • ${p.description}'}'),
                                trailing: Text(Formatters.amount(p.amount), style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.green)),
                              ),
                            );
                          },
                        ),
                ),
      floatingActionButton: FloatingActionButton.extended(onPressed: _receive, icon: const Icon(Icons.add), label: const Text('Receive')),
    );
  }
}

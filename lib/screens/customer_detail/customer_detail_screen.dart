import 'package:flutter/material.dart';

import '../../models/customer.dart';
import '../../models/ledger_entry.dart';
import '../../services/api_client.dart';
import '../../utils/formatters.dart';
import '../../utils/json_utils.dart';
import '../../widgets/pro_widgets.dart';
import '../payments/receive_payment_screen.dart';

class CustomerDetailScreen extends StatefulWidget {
  final Customer customer;
  const CustomerDetailScreen({super.key, required this.customer});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  bool _loading = true;
  String _error = '';
  List<LedgerEntry> _ledger = [];

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
      final res = await ApiClient.instance.get('/api/customers/${widget.customer.publicId}/ledger', query: {'limit': 100});
      final rows = JsonUtils.list(res['data']);
      setState(() => _ledger = rows.map((e) => LedgerEntry.fromJson(JsonUtils.map(e))).toList());
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _receivePayment() async {
    final changed = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => ReceivePaymentScreen(customer: widget.customer)));
    if (changed == true) {
      await _load();
      if (mounted) Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.customer.customerName)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(_error, textAlign: TextAlign.center))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      GradientHeaderCard(
                        title: 'Current balance',
                        subtitle: widget.customer.phoneNumber ?? '',
                        amount: Formatters.amount(widget.customer.currentBalance),
                        footer: widget.customer.currentBalance > 0 ? 'Customer has pending receivable.' : 'No pending amount for this customer.',
                        icon: Icons.person_rounded,
                      ),
                      const SizedBox(height: 16),
                      SectionCard(
                        title: 'Ledger / Khata',
                        subtitle: 'Sales and payment history',
                        trailing: TextButton.icon(onPressed: _receivePayment, icon: const Icon(Icons.payments_rounded), label: const Text('Payment')),
                        child: _ledger.isEmpty
                            ? const SizedBox(height: 120, child: Center(child: Text('No ledger entries yet.')))
                            : Column(
                                children: _ledger.map((e) {
                                  final isDebit = e.debitAmount > 0;
                                  return Column(
                                    children: [
                                      ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        leading: CircleAvatar(
                                          backgroundColor: (isDebit ? Colors.red : Colors.green).withOpacity(0.10),
                                          child: Icon(isDebit ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, color: isDebit ? Colors.red : Colors.green),
                                        ),
                                        title: Text(e.description.isEmpty ? e.entryType : e.description, style: const TextStyle(fontWeight: FontWeight.w800)),
                                        subtitle: Text('${Formatters.date(e.ledgerDate)} • Balance: ${Formatters.amount(e.balanceAfter)}'),
                                        trailing: Text(isDebit ? Formatters.amount(e.debitAmount) : Formatters.amount(e.creditAmount), style: TextStyle(fontWeight: FontWeight.w900, color: isDebit ? Colors.red : Colors.green)),
                                      ),
                                      const Divider(height: 1),
                                    ],
                                  );
                                }).toList(),
                              ),
                      ),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(onPressed: _receivePayment, icon: const Icon(Icons.payments_rounded), label: const Text('Receive')),
    );
  }
}

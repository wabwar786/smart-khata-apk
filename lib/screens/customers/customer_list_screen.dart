import 'package:flutter/material.dart';

import '../../models/customer.dart';
import '../../services/api_client.dart';
import '../../utils/formatters.dart';
import 'customer_form_screen.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  bool _loading = true;
  String _error = '';
  List<Customer> _customers = [];

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
      final res = await ApiClient.instance.get('/api/customers', query: {'limit': 100});
      final rows = (res['data'] as List<dynamic>? ?? []);
      setState(() => _customers = rows.map((e) => Customer.fromJson(e as Map<String, dynamic>)).toList());
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openAdd() async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const CustomerFormScreen()),
    );
    if (changed == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Scaffold(
      body: _error.isNotEmpty
          ? Center(child: Text(_error))
          : RefreshIndicator(
              onRefresh: _load,
              child: _customers.isEmpty
                  ? const Center(child: Text('No customers yet. Tap + to add.'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemBuilder: (_, i) {
                        final c = _customers[i];
                        return Card(
                          child: ListTile(
                            leading: const CircleAvatar(child: Icon(Icons.person_rounded)),
                            title: Text(c.customerName, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text([c.phoneNumber, c.city].where((x) => x != null && x.isNotEmpty).join(' • ')),
                            trailing: Text(Formatters.amount(c.currentBalance), style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 4),
                      itemCount: _customers.length,
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAdd,
        icon: const Icon(Icons.add),
        label: const Text('Customer'),
      ),
    );
  }
}

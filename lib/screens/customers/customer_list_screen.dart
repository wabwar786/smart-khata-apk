import 'package:flutter/material.dart';

import '../../models/customer.dart';
import '../../services/api_client.dart';
import '../../utils/formatters.dart';
import '../../utils/json_utils.dart';
import '../customer_detail/customer_detail_screen.dart';
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
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final res = await ApiClient.instance.get('/api/customers', query: {'limit': 100, 'search': _search.text.trim()});
      final rows = JsonUtils.list(res['data']);
      setState(() => _customers = rows.map((e) => Customer.fromJson(JsonUtils.map(e))).toList());
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openAdd() async {
    final changed = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => const CustomerFormScreen()));
    if (changed == true) _load();
  }

  Future<void> _openDetail(Customer customer) async {
    final changed = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => CustomerDetailScreen(customer: customer)));
    if (changed == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Scaffold(
      body: _error.isNotEmpty
          ? Center(child: Text(_error, textAlign: TextAlign.center))
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text('Customers', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _search,
                    decoration: InputDecoration(
                      hintText: 'Search customer or phone',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: IconButton(icon: const Icon(Icons.arrow_forward_rounded), onPressed: _load),
                    ),
                    onSubmitted: (_) => _load(),
                  ),
                  const SizedBox(height: 12),
                  if (_customers.isEmpty)
                    const SizedBox(height: 220, child: Center(child: Text('No customers yet. Tap + to add.')))
                  else
                    ..._customers.map((c) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Card(
                            child: ListTile(
                              onTap: () => _openDetail(c),
                              leading: CircleAvatar(backgroundColor: const Color(0xFF0F766E).withOpacity(0.10), child: const Icon(Icons.person_rounded, color: Color(0xFF0F766E))),
                              title: Text(c.customerName, style: const TextStyle(fontWeight: FontWeight.w800)),
                              subtitle: Text([c.phoneNumber ?? '', c.city ?? ''].where((e) => e.isNotEmpty).join(' • ')),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(Formatters.amount(c.currentBalance), style: TextStyle(fontWeight: FontWeight.w900, color: c.currentBalance > 0 ? const Color(0xFFDC2626) : const Color(0xFF0F766E))),
                                  const Text('Balance', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                ],
                              ),
                            ),
                          ),
                        )),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(onPressed: _openAdd, icon: const Icon(Icons.add), label: const Text('Customer')),
    );
  }
}

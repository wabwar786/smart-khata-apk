import 'package:flutter/material.dart';

import '../services/api_client.dart';
import '../utils/formatters.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _loading = true;
  String _error = '';
  Map<String, dynamic> _summary = {};

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
      final res = await ApiClient.instance.get('/api/dashboard/summary');
      setState(() => _summary = (res['data'] ?? {}) as Map<String, dynamic>);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _Card(title: 'Today Sales', value: Formatters.amount(_summary['todaySales']), icon: Icons.payments_rounded),
          _Card(title: 'Today Invoices', value: _summary['todayInvoices']?.toString() ?? '0', icon: Icons.receipt_rounded),
          _Card(title: 'Receivable', value: Formatters.amount(_summary['receivable']), icon: Icons.account_balance_wallet_rounded),
          _Card(title: 'Customers', value: _summary['totalCustomers']?.toString() ?? '0', icon: Icons.people_alt_rounded),
          _Card(title: 'Products', value: _summary['totalProducts']?.toString() ?? '0', icon: Icons.inventory_rounded),
          _Card(title: 'Low Stock', value: _summary['lowStock']?.toString() ?? '0', icon: Icons.warning_rounded),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _Card({required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title),
        trailing: Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../services/api_client.dart';
import '../utils/formatters.dart';
import '../utils/json_utils.dart';
import '../widgets/pro_widgets.dart';
import 'customers/customer_form_screen.dart';
import 'invoices/create_invoice_screen.dart';
import 'payments/receive_payment_screen.dart';
import 'products/product_form_screen.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onDataChanged;
  const DashboardScreen({super.key, this.onDataChanged});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _loading = true;
  String _error = '';
  Map<String, dynamic> _summary = {};
  List<SalesPoint> _salesTrend = [];

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
      final summaryRes = await ApiClient.instance.get('/api/dashboard/summary');
      final salesRes = await ApiClient.instance.get('/api/dashboard/sales-daily', query: {'days': 7});
      final rows = JsonUtils.list(salesRes['data']);
      setState(() {
        _summary = JsonUtils.map(summaryRes['data']);
        _salesTrend = rows.map((e) {
          final row = JsonUtils.map(e);
          final date = row['sale_date'] ?? row['saleDate'];
          return SalesPoint(
            label: Formatters.date(date),
            shortLabel: Formatters.shortDate(date),
            value: JsonUtils.number(row['total_sales'] ?? row['totalSales']),
          );
        }).toList();
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _open(Widget screen) async {
    final changed = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => screen));
    if (changed == true) {
      await _load();
      widget.onDataChanged?.call();
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

    final receivable = JsonUtils.number(_summary['receivable']);
    final todaySales = JsonUtils.number(_summary['todaySales']);
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        children: [
          GradientHeaderCard(
            title: 'Today sales',
            subtitle: '${JsonUtils.integer(_summary['todayInvoices'])} invoices today',
            amount: Formatters.amount(todaySales),
            footer: receivable > 0 ? 'Receivable pending: ${Formatters.amount(receivable)}' : 'No receivable balance yet. Keep selling!',
            icon: Icons.trending_up_rounded,
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, c) {
              final width = (c.maxWidth - 12) / 2;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(width: width, height: 152, child: StatCard(title: 'Receivable', value: Formatters.amount(receivable), icon: Icons.account_balance_wallet_rounded, color: const Color(0xFF2563EB), caption: 'Customer pending')),
                  SizedBox(width: width, height: 152, child: StatCard(title: 'Customers', value: JsonUtils.str(_summary['totalCustomers'], '0'), icon: Icons.people_alt_rounded, color: const Color(0xFF7C3AED), caption: 'Total parties')),
                  SizedBox(width: width, height: 152, child: StatCard(title: 'Products', value: JsonUtils.str(_summary['totalProducts'], '0'), icon: Icons.inventory_2_rounded, color: const Color(0xFFEA580C), caption: 'Stock items/services')),
                  SizedBox(width: width, height: 152, child: StatCard(title: 'Low Stock', value: JsonUtils.str(_summary['lowStock'], '0'), icon: Icons.warning_amber_rounded, color: const Color(0xFFDC2626), caption: 'Needs attention')),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Sales trend',
            subtitle: 'Last 7 days sales performance',
            child: SalesMiniChart(data: _salesTrend),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Quick actions',
            subtitle: 'Daily work shortcuts',
            child: Column(
              children: [
                QuickActionTile(title: 'Create invoice', subtitle: 'Add sale and update ledger', icon: Icons.receipt_long_rounded, onTap: () => _open(const CreateInvoiceScreen())),
                const SizedBox(height: 10),
                QuickActionTile(title: 'Receive payment', subtitle: 'Record cash/bank payment', icon: Icons.payments_rounded, onTap: () => _open(const ReceivePaymentScreen())),
                const SizedBox(height: 10),
                QuickActionTile(title: 'Add customer', subtitle: 'Create party/customer record', icon: Icons.person_add_alt_1_rounded, onTap: () => _open(const CustomerFormScreen())),
                const SizedBox(height: 10),
                QuickActionTile(title: 'Add product', subtitle: 'Create product or service', icon: Icons.add_box_rounded, onTap: () => _open(const ProductFormScreen())),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

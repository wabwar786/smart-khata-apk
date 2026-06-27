import 'package:flutter/material.dart';

import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/json_utils.dart';
import '../widgets/sk_widgets.dart';
import 'party/add_party_screen.dart';
import 'party/party_action_screen.dart';
import 'inventory/inventory_home_screen.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onDataChanged;
  const DashboardScreen({super.key, this.onDataChanged});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _search = TextEditingController();
  bool _loading = true;
  String _error = '';
  List<Map<String, dynamic>> _customers = [];
  List<Map<String, dynamic>> _suppliers = [];
  List<Map<String, dynamic>> _products = [];

  @override
  void initState() { super.initState(); _tab = TabController(length: 3, vsync: this); _load(); }
  @override
  void dispose() { _tab.dispose(); _search.dispose(); super.dispose(); }

  List<Map<String, dynamic>> _rows(dynamic data) => JsonUtils.list(data).map((e) => JsonUtils.map(e)).toList();

  Future<void> _load() async {
    setState(() { _loading = true; _error = ''; });
    try {
      final c = await ApiClient.instance.get('/api/customers', query: {'limit': 100});
      final s = await ApiClient.instance.get('/api/suppliers', query: {'limit': 100});
      final p = await ApiClient.instance.get('/api/products', query: {'limit': 100});
      setState(() {
        _customers = _rows(c['data']);
        _suppliers = _rows(s['data']);
        _products = _rows(p['data']);
      });
    } catch (e) { setState(() => _error = e.toString()); }
    finally { if (mounted) setState(() => _loading = false); }
  }

  double _sum(List<Map<String, dynamic>> rows, List<String> keys, {bool positiveOnly = false}) {
    double total = 0;
    for (final r in rows) {
      final v = JsonUtils.number(keys.map((k) => r[k]).firstWhere((v) => v != null, orElse: () => 0));
      if (!positiveOnly || v > 0) total += v;
    }
    return total;
  }

  List<Map<String, dynamic>> _filter(List<Map<String, dynamic>> rows, String nameKey, String phoneKey) {
    final q = _search.text.toLowerCase().trim();
    if (q.isEmpty) return rows;
    return rows.where((r) => JsonUtils.str(r[nameKey] ?? r[_camel(nameKey)]).toLowerCase().contains(q) || JsonUtils.str(r[phoneKey] ?? r[_camel(phoneKey)]).contains(q)).toList();
  }

  String _camel(String snake) => snake.replaceAllMapped(RegExp(r'_([a-z])'), (m) => m[1]!.toUpperCase());

  Future<void> _addParty(String type) async {
    final saved = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => AddPartyScreen(partyType: type)));
    if (saved == true) { await _load(); widget.onDataChanged?.call(); }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error.isNotEmpty) return Center(child: Padding(padding: const EdgeInsets.all(22), child: Column(mainAxisSize: MainAxisSize.min, children: [Text(_error, textAlign: TextAlign.center), const SizedBox(height: 12), ElevatedButton(onPressed: _load, child: const Text('Retry'))])));
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
        child: Container(
          height: 50,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: const Color(0xFFEAF8FF), borderRadius: BorderRadius.circular(24)),
          child: TabBar(controller: _tab, indicator: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)), labelColor: AppColors.primary, unselectedLabelColor: AppColors.text, labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900), tabs: const [Tab(text: 'Customers'), Tab(text: 'Suppliers'), Tab(text: 'Inventory')]),
        ),
      ),
      Padding(padding: const EdgeInsets.fromLTRB(16, 14, 16, 6), child: SearchBox(controller: _search, hint: 'Search customer, supplier or item', onChanged: (_) => setState(() {}))),
      Expanded(child: RefreshIndicator(onRefresh: _load, child: TabBarView(controller: _tab, children: [_customerTab(), _supplierTab(), _inventoryTab()]))),
    ]);
  }

  Widget _customerTab() {
    final rows = _filter(_customers, 'customerName', 'phoneNumber');
    final receivable = _sum(_customers, ['currentBalance']);
    return ListView(padding: const EdgeInsets.all(16), children: [
      Row(children: [Expanded(child: MoneyCard(title: 'Receivable', amount: receivable, icon: Icons.call_received_rounded, color: AppColors.green)), const SizedBox(width: 10), Expanded(child: MoneyCard(title: 'Payable', amount: 0, icon: Icons.call_made_rounded, color: AppColors.orange))]),
      const SizedBox(height: 14),
      PillButton(text: 'ADD CUSTOMER', icon: Icons.person_add_alt_1_rounded, onTap: () => _addParty('customer')),
      const SizedBox(height: 14),
      if (rows.isEmpty) const SizedBox(height: 320, child: EmptyState(icon: Icons.people_alt_rounded, title: 'No customers found', subtitle: 'Add customer manually or import from phone contacts.')),
      for (final r in rows) _partyTile('customer', r, JsonUtils.str(r['customerName']), JsonUtils.str(r['phoneNumber']), JsonUtils.number(r['currentBalance'])),
    ]);
  }

  Widget _supplierTab() {
    final rows = _filter(_suppliers, 'supplier_name', 'phone_number');
    final payable = _sum(_suppliers, ['current_balance', 'currentBalance']);
    return ListView(padding: const EdgeInsets.all(16), children: [
      Row(children: [Expanded(child: MoneyCard(title: 'Receivable', amount: 0, icon: Icons.call_received_rounded, color: AppColors.green)), const SizedBox(width: 10), Expanded(child: MoneyCard(title: 'Payable', amount: payable, icon: Icons.call_made_rounded, color: AppColors.orange))]),
      const SizedBox(height: 14),
      PillButton(text: 'ADD SUPPLIER', icon: Icons.add_business_rounded, onTap: () => _addParty('supplier')),
      const SizedBox(height: 14),
      if (rows.isEmpty) const SizedBox(height: 320, child: EmptyState(icon: Icons.store_rounded, title: 'No suppliers found', subtitle: 'Add suppliers and manage purchase/payment khata.')),
      for (final r in rows) _partyTile('supplier', r, JsonUtils.str(r['supplier_name'] ?? r['supplierName']), JsonUtils.str(r['phone_number'] ?? r['phoneNumber']), JsonUtils.number(r['current_balance'] ?? r['currentBalance'])),
    ]);
  }

  Widget _inventoryTab() {
    final q = _search.text.toLowerCase().trim();
    final rows = q.isEmpty ? _products : _products.where((r) => JsonUtils.str(r['productName']).toLowerCase().contains(q)).toList();
    final stockValue = _products.fold<double>(0, (t, r) => t + JsonUtils.number(r['purchasePrice']) * JsonUtils.number(r['currentStock']));
    final low = _products.where((r) => JsonUtils.number(r['currentStock']) <= JsonUtils.number(r['lowStockQty'], -1) && JsonUtils.number(r['lowStockQty'], -1) >= 0).length;
    return ListView(padding: const EdgeInsets.all(16), children: [
      Row(children: [Expanded(child: MoneyCard(title: 'Total Stock Value', amount: stockValue, icon: Icons.inventory_rounded, color: const Color(0xFF2563EB))), const SizedBox(width: 10), Expanded(child: MoneyCard(title: 'Reorder List', amount: low, icon: Icons.warning_amber_rounded, color: AppColors.orange, footer: 'Items'))]),
      const SizedBox(height: 14),
      PillButton(text: 'CREATE / ADD ITEM', icon: Icons.add_box_rounded, onTap: () async { await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddInventoryItemScreen())); _load(); }),
      const SizedBox(height: 14),
      if (rows.isEmpty) const SizedBox(height: 320, child: EmptyState(icon: Icons.inventory_2_rounded, title: 'No inventory found', subtitle: 'Add items with purchase price, sale price and stock.')),
      for (final r in rows) _productTile(r),
    ]);
  }

  Widget _partyTile(String type, Map<String, dynamic> r, String name, String phone, double balance) {
    final publicId = JsonUtils.str(r['publicId'] ?? r['public_id']);
    return Card(margin: const EdgeInsets.only(bottom: 10), child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      leading: CircleAvatar(backgroundColor: AppColors.primary.withAlpha(20), child: Text(name.isEmpty ? '?' : name[0].toUpperCase(), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900))),
      title: Text(name, style: AppText.h3), subtitle: Text('$phone • ${balance >= 0 ? 'Receivable' : 'Payable'}', style: AppText.small),
      trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [Text(Formatters.amount(balance.abs()), style: TextStyle(fontWeight: FontWeight.w900, color: balance >= 0 ? AppColors.green : AppColors.orange)), const SizedBox(height: 2), const Icon(Icons.chevron_right_rounded, color: AppColors.muted)]),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PartyActionScreen(partyType: type, publicId: publicId, name: name, phone: phone))),
    ));
  }

  Widget _productTile(Map<String, dynamic> r) {
    final qty = JsonUtils.number(r['currentStock']);
    final low = JsonUtils.number(r['lowStockQty'], -1);
    return Card(margin: const EdgeInsets.only(bottom: 10), child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.sky, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.inventory_2_rounded, color: AppColors.primary)),
      title: Text(JsonUtils.str(r['productName']), style: AppText.h3),
      subtitle: Text('Stock: ${qty.toStringAsFixed(qty.truncateToDouble() == qty ? 0 : 2)} • Buy ${Formatters.amount(r['purchasePrice'])}', style: AppText.small),
      trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [Text(Formatters.amount(r['salePrice']), style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w900)), Text(low >= 0 && qty <= low ? 'Reorder' : 'OK', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: low >= 0 && qty <= low ? AppColors.orange : AppColors.muted))]),
    ));
  }
}

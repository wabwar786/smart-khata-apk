import 'package:flutter/material.dart';

import '../../services/api_client.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../utils/json_utils.dart';
import '../../widgets/error_box.dart';
import '../../widgets/sk_widgets.dart';

class InventoryHomeScreen extends StatefulWidget {
  final VoidCallback? onChanged;
  const InventoryHomeScreen({super.key, this.onChanged});
  @override
  State<InventoryHomeScreen> createState() => _InventoryHomeScreenState();
}

class _InventoryHomeScreenState extends State<InventoryHomeScreen> {
  final _search = TextEditingController();
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  String _error = '';

  @override
  void initState() { super.initState(); _load(); }
  @override
  void dispose() { _search.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = ''; });
    try { final res = await ApiClient.instance.get('/api/products', query: {'limit': 200}); setState(() => _items = JsonUtils.list(res['data']).map((e) => JsonUtils.map(e)).toList()); }
    catch (e) { setState(() => _error = e.toString()); }
    finally { if (mounted) setState(() => _loading = false); }
  }

  double _stockValue() => _items.fold(0, (t, e) => t + JsonUtils.number(e['purchasePrice']) * JsonUtils.number(e['currentStock']));
  int _lowCount() => _items.where((e) { final low = JsonUtils.number(e['lowStockQty'], -1); return low >= 0 && JsonUtils.number(e['currentStock']) <= low; }).length;

  Future<void> _openAdd() async {
    final saved = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => const AddInventoryItemScreen()));
    if (saved == true) { await _load(); widget.onChanged?.call(); }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final q = _search.text.toLowerCase().trim();
    final rows = q.isEmpty ? _items : _items.where((e) => JsonUtils.str(e['productName']).toLowerCase().contains(q)).toList();
    return RefreshIndicator(onRefresh: _load, child: ListView(padding: const EdgeInsets.all(16), children: [
      ErrorBox(_error),
      Row(children: [Expanded(child: MoneyCard(title: 'Total Items', amount: _items.length, icon: Icons.apps_rounded, color: AppColors.primary, footer: 'Items')), const SizedBox(width: 10), Expanded(child: MoneyCard(title: 'Stock Value', amount: _stockValue(), icon: Icons.account_balance_wallet_rounded, color: const Color(0xFF2563EB)))]),
      const SizedBox(height: 10),
      MoneyCard(title: 'Low Stock / Reorder Items', amount: _lowCount(), icon: Icons.warning_amber_rounded, color: AppColors.orange, footer: 'Need attention'),
      const SizedBox(height: 14),
      SearchBox(controller: _search, hint: 'Search item', onChanged: (_) => setState(() {})),
      const SizedBox(height: 14),
      PillButton(text: 'CREATE ITEM / ADD STOCK', icon: Icons.add_box_rounded, onTap: _openAdd),
      const SizedBox(height: 14),
      if (rows.isEmpty) const SizedBox(height: 300, child: EmptyState(icon: Icons.inventory_2_rounded, title: 'No item found', subtitle: 'Create item with purchase price, sale price and opening stock.')),
      for (final r in rows) _itemTile(r),
    ]));
  }

  Widget _itemTile(Map<String, dynamic> r) {
    final qty = JsonUtils.number(r['currentStock']);
    final low = JsonUtils.number(r['lowStockQty'], -1);
    final reorder = low >= 0 && qty <= low;
    return Card(margin: const EdgeInsets.only(bottom: 10), child: ListTile(
      leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: reorder ? AppColors.orange.withAlpha(20) : AppColors.sky, borderRadius: BorderRadius.circular(14)), child: Icon(reorder ? Icons.warning_amber_rounded : Icons.inventory_2_rounded, color: reorder ? AppColors.orange : AppColors.primary)),
      title: Text(JsonUtils.str(r['productName']), style: AppText.h3),
      subtitle: Text('Qty: ${qty.toStringAsFixed(qty.truncateToDouble() == qty ? 0 : 2)} • Buy ${Formatters.amount(r['purchasePrice'])} • Sale ${Formatters.amount(r['salePrice'])}', style: AppText.small),
      trailing: Text(reorder ? 'REORDER' : Formatters.amount(JsonUtils.number(r['purchasePrice']) * qty), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: reorder ? AppColors.orange : AppColors.green)),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => StockAdjustmentScreen(item: r))).then((_) => _load()),
    ));
  }
}

class AddInventoryItemScreen extends StatefulWidget {
  const AddInventoryItemScreen({super.key});
  @override
  State<AddInventoryItemScreen> createState() => _AddInventoryItemScreenState();
}

class _AddInventoryItemScreenState extends State<AddInventoryItemScreen> {
  final _name = TextEditingController();
  final _purchase = TextEditingController();
  final _sale = TextEditingController();
  final _stock = TextEditingController();
  final _reorder = TextEditingController();
  bool _saving = false;
  String _error = '';
  @override
  void dispose() { _name.dispose(); _purchase.dispose(); _sale.dispose(); _stock.dispose(); _reorder.dispose(); super.dispose(); }
  Future<void> _save() async {
    if (_name.text.trim().isEmpty) { setState(() => _error = 'Item name is required.'); return; }
    setState(() { _saving = true; _error = ''; });
    try {
      await ApiClient.instance.post('/api/products', {
        'productName': _name.text.trim(), 'productType': 'PRODUCT', 'unitId': 1, 'purchasePrice': double.tryParse(_purchase.text) ?? 0, 'salePrice': double.tryParse(_sale.text) ?? 0, 'openingStock': double.tryParse(_stock.text) ?? 0, 'lowStockQty': double.tryParse(_reorder.text) ?? 0,
      });
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) { setState(() => _error = e.toString()); }
    finally { if (mounted) setState(() => _saving = false); }
  }
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Create Item')), body: SafeArea(child: ListView(padding: const EdgeInsets.all(18), children: [
    ErrorBox(_error),
    Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)), child: Column(children: [
      TextField(controller: _name, decoration: const InputDecoration(labelText: 'Item name *', prefixIcon: Icon(Icons.inventory_2_rounded))), const SizedBox(height: 12),
      Row(children: [Expanded(child: TextField(controller: _purchase, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Purchase price'))), const SizedBox(width: 10), Expanded(child: TextField(controller: _sale, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Sale price')))]), const SizedBox(height: 12),
      Row(children: [Expanded(child: TextField(controller: _stock, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Opening stock'))), const SizedBox(width: 10), Expanded(child: TextField(controller: _reorder, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Reorder level')))]),
    ])), const SizedBox(height: 18), PillButton(text: _saving ? 'SAVING...' : 'SAVE ITEM', icon: Icons.check_rounded, onTap: _saving ? null : _save)
  ])));
}

class StockAdjustmentScreen extends StatefulWidget {
  final Map<String, dynamic> item;
  const StockAdjustmentScreen({super.key, required this.item});
  @override
  State<StockAdjustmentScreen> createState() => _StockAdjustmentScreenState();
}

class _StockAdjustmentScreenState extends State<StockAdjustmentScreen> {
  final _qty = TextEditingController();
  String _type = 'IN';
  bool _saving = false;
  String _error = '';
  @override
  void dispose() { _qty.dispose(); super.dispose(); }
  Future<void> _save() async {
    final qty = double.tryParse(_qty.text) ?? 0;
    if (qty <= 0) { setState(() => _error = 'Enter valid quantity.'); return; }
    setState(() { _saving = true; _error = ''; });
    try {
      await ApiClient.instance.post('/api/products/${JsonUtils.str(widget.item['publicId'])}/stock-adjustment', {'adjustmentType': _type, 'qty': qty, 'notes': _type == 'IN' ? 'Stock in from app' : 'Stock out from app'});
      if (!mounted) return; Navigator.pop(context, true);
    } catch (e) { setState(() => _error = e.toString()); }
    finally { if (mounted) setState(() => _saving = false); }
  }
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Stock In / Out')), body: SafeArea(child: ListView(padding: const EdgeInsets.all(18), children: [
    ErrorBox(_error), Text(JsonUtils.str(widget.item['productName']), style: AppText.h2), const SizedBox(height: 14),
    SegmentedButton<String>(segments: const [ButtonSegment(value: 'IN', label: Text('Stock In')), ButtonSegment(value: 'OUT', label: Text('Stock Out'))], selected: {_type}, onSelectionChanged: (s) => setState(() => _type = s.first)),
    const SizedBox(height: 14), TextField(controller: _qty, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantity', prefixIcon: Icon(Icons.numbers_rounded))),
    const SizedBox(height: 18), PillButton(text: _saving ? 'SAVING...' : 'SAVE STOCK', icon: Icons.check_rounded, onTap: _saving ? null : _save)
  ])));
}

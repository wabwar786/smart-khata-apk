import 'package:flutter/material.dart';

import '../../services/api_client.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../utils/json_utils.dart';
import '../../widgets/sk_widgets.dart';
import 'sale_success_screen.dart';

class SaleItemDraft {
  String name;
  double price;
  double qty;
  String? productPublicId;
  SaleItemDraft({required this.name, required this.price, this.qty = 1, this.productPublicId});
  double get total => price * qty;
}

class PosScreen extends StatefulWidget {
  final VoidCallback? onSaved;
  final String? prefilledCustomerId;
  final String? prefilledCustomerName;
  const PosScreen({super.key, this.onSaved, this.prefilledCustomerId, this.prefilledCustomerName});
  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  int _mode = 0;
  String _amount = '';
  final _itemName = TextEditingController(text: 'Item 1');
  final _discount = TextEditingController(text: '0');
  final List<SaleItemDraft> _items = [];
  List<Map<String, dynamic>> _products = [];
  bool _saving = false;
  String _error = '';

  @override
  void initState() { super.initState(); _loadProducts(); }
  @override
  void dispose() { _itemName.dispose(); _discount.dispose(); super.dispose(); }

  Future<void> _loadProducts() async {
    try { final res = await ApiClient.instance.get('/api/products', query: {'limit': 100}); setState(() => _products = JsonUtils.list(res['data']).map((e) => JsonUtils.map(e)).toList()); } catch (_) {}
  }

  double get _entered => double.tryParse(_amount) ?? 0;
  double get _subTotal => _items.fold<double>(0, (t, x) => t + x.total) + (_entered > 0 ? _entered : 0);
  double get _discountAmount => double.tryParse(_discount.text.trim()) ?? 0;
  double get _total => (_subTotal - _discountAmount).clamp(0, double.infinity);

  void _key(String v) {
    setState(() {
      if (v == 'back') { if (_amount.isNotEmpty) _amount = _amount.substring(0, _amount.length - 1); return; }
      if (v == '.') { if (!_amount.contains('.')) _amount += '.'; return; }
      if (v == '00' && _amount.isEmpty) return;
      _amount += v;
    });
  }

  void _addEnteredItem() {
    if (_entered <= 0) return;
    setState(() { _items.add(SaleItemDraft(name: _itemName.text.trim().isEmpty ? 'Open Item' : _itemName.text.trim(), price: _entered)); _amount = ''; _itemName.text = 'Item ${_items.length + 1}'; });
  }

  Future<void> _chooseProduct() async {
    final product = await showModalBottomSheet<Map<String, dynamic>>(context: context, showDragHandle: true, builder: (_) => ListView(
      children: [const Padding(padding: EdgeInsets.all(16), child: Text('Select inventory item', style: AppText.h3)), for (final p in _products) ListTile(title: Text(JsonUtils.str(p['productName'])), subtitle: Text('Stock ${JsonUtils.number(p['currentStock'])} • ${Formatters.amount(p['salePrice'])}'), trailing: const Icon(Icons.add_rounded), onTap: () => Navigator.pop(context, p))],
    ));
    if (product != null) setState(() => _items.add(SaleItemDraft(name: JsonUtils.str(product['productName']), price: JsonUtils.number(product['salePrice']), productPublicId: JsonUtils.str(product['publicId']))));
  }

  Future<void> _save(String paymentType) async {
    if (_entered > 0) _addEnteredItem();
    if (_items.isEmpty || _total <= 0) { setState(() => _error = 'Please add at least one sale item.'); return; }
    setState(() { _saving = true; _error = ''; });
    try {
      final res = await ApiClient.instance.post('/api/pos/sale', {
        'customerPublicId': widget.prefilledCustomerId,
        'customerName': widget.prefilledCustomerName,
        'invoiceType': _items.any((e) => e.productPublicId != null) ? 'inventory_item' : 'open_item',
        'paymentType': paymentType,
        'discountAmount': _discountAmount,
        'items': _items.map((e) => {'productPublicId': e.productPublicId, 'itemName': e.name, 'qty': e.qty, 'unitPrice': e.price}).toList(),
      });
      widget.onSaved?.call();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => SaleSuccessScreen(total: _total, paymentType: paymentType, invoice: JsonUtils.map(res['data']), items: List.of(_items))));
    } catch (e) { setState(() => _error = e.toString()); }
    finally { if (mounted) setState(() => _saving = false); }
  }

  Future<void> _paymentSheet() async {
    if (_entered > 0) _addEnteredItem();
    if (_items.isEmpty || _total <= 0) { setState(() => _error = 'Please enter item amount first.'); return; }
    await showModalBottomSheet<void>(context: context, showDragHandle: true, builder: (_) => Padding(padding: const EdgeInsets.all(18), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)), child: Column(children: [const Text('Sale amount', style: AppText.small), const SizedBox(height: 6), Text(Formatters.amount(_total), style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900))])),
      const SizedBox(height: 24),
      const Text('Payment ka tareeka select karein', style: AppText.h3),
      RadioListTile<String>(value: 'ONLINE', groupValue: 'CASH', onChanged: (_) {}, title: const Text('Collect online'), secondary: const Icon(Icons.account_balance_rounded)),
      RadioListTile<String>(value: 'UDHAAR', groupValue: 'CASH', onChanged: (_) { Navigator.pop(context); _save('UDHAAR'); }, title: const Text('Udhaar'), secondary: const Icon(Icons.menu_book_rounded)),
      RadioListTile<String>(value: 'CASH', groupValue: 'CASH', onChanged: (_) {}, title: const Text('Cash'), secondary: const Icon(Icons.payments_rounded)),
      const SizedBox(height: 12),
      PillButton(text: _saving ? 'SAVING...' : 'RECORD CASH SALE', icon: Icons.check_rounded, onTap: _saving ? null : () { Navigator.pop(context); _save('CASH'); }),
      const SizedBox(height: 8),
    ])));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sale POS'), leading: Navigator.canPop(context) ? const BackButton() : null, actions: [IconButton(onPressed: _chooseProduct, icon: const Icon(Icons.search_rounded)), IconButton(onPressed: _chooseProduct, icon: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.green))]),
      body: SafeArea(child: Column(children: [
        Padding(padding: const EdgeInsets.all(16), child: Container(height: 48, padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: const Color(0xFFEAF8FF), borderRadius: BorderRadius.circular(22)), child: Row(children: [
          _modeButton('Khulla item', 0), _modeButton('Stock list', 1), _modeButton('Catalog', 2),
        ]))),
        if (_error.isNotEmpty) Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text(_error, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w700))),
        Expanded(child: _mode == 0 ? _openItem() : _stockList()),
        Padding(padding: const EdgeInsets.fromLTRB(16, 6, 16, 16), child: PillButton(text: _total <= 0 ? 'NEXT      Rs. 0' : 'NEXT      ${Formatters.amount(_total)}', icon: Icons.arrow_forward_rounded, color: _total <= 0 ? const Color(0xFFE0E0E0) : AppColors.green, foreground: _total <= 0 ? AppColors.muted : Colors.white, onTap: _total <= 0 ? null : _paymentSheet)),
      ])),
    );
  }

  Widget _modeButton(String t, int i) => Expanded(child: GestureDetector(onTap: () => setState(() => _mode = i), child: Container(alignment: Alignment.center, decoration: BoxDecoration(color: _mode == i ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(18)), child: Text(t, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: _mode == i ? AppColors.primary : AppColors.text)))));

  Widget _openItem() => ListView(padding: const EdgeInsets.fromLTRB(16, 24, 16, 0), children: [
    const Text('Enter item amount', style: AppText.h2),
    const SizedBox(height: 14),
    Text('Rs.${_amount.isEmpty ? '0' : _amount}', style: TextStyle(fontSize: 56, fontWeight: FontWeight.w900, color: _amount.isEmpty ? Colors.grey.shade300 : AppColors.text)),
    const SizedBox(height: 8),
    TextField(controller: _itemName, decoration: const InputDecoration(labelText: 'Item name optional', prefixIcon: Icon(Icons.edit_note_rounded))),
    const SizedBox(height: 8),
    TextField(controller: _discount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Discount optional', prefixIcon: Icon(Icons.discount_rounded))),
    const SizedBox(height: 20),
    if (_items.isNotEmpty) ..._items.asMap().entries.map((e) => ListTile(contentPadding: EdgeInsets.zero, title: Text(e.value.name), subtitle: Text('Qty ${e.value.qty}'), trailing: Text(Formatters.amount(e.value.total)), leading: IconButton(icon: const Icon(Icons.delete_outline_rounded, color: Colors.red), onPressed: () => setState(() => _items.removeAt(e.key))))),
    const SizedBox(height: 10),
    GridView.count(crossAxisCount: 4, shrinkWrap: true, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.55, physics: const NeverScrollableScrollPhysics(), children: [
      for (final k in ['7','8','9','back','4','5','6','+','1','2','3','=','0','00','.']) _keyButton(k),
    ]),
  ]);

  Widget _keyButton(String k) => InkWell(onTap: () { if (k == '+' || k == '=') { _addEnteredItem(); } else { _key(k); } }, borderRadius: BorderRadius.circular(14), child: Container(alignment: Alignment.center, decoration: BoxDecoration(color: (k == '+' || k == '=' || k == 'back') ? AppColors.primary.withAlpha(14) : Colors.white, borderRadius: BorderRadius.circular(14)), child: (k == 'back' || k == '+' || k == '=') ? Icon(k == 'back' ? Icons.backspace_outlined : k == '+' ? Icons.add_rounded : Icons.drag_handle_rounded, color: AppColors.primary) : Text(k, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700))));

  Widget _stockList() => ListView(padding: const EdgeInsets.all(16), children: [
    if (_products.isEmpty) const SizedBox(height: 300, child: EmptyState(icon: Icons.inventory_2_rounded, title: 'No stock items', subtitle: 'Add inventory items first, then sale from stock list.')),
    for (final p in _products) Card(margin: const EdgeInsets.only(bottom: 10), child: ListTile(title: Text(JsonUtils.str(p['productName']), style: AppText.h3), subtitle: Text('Stock ${JsonUtils.number(p['currentStock'])}', style: AppText.small), trailing: Text(Formatters.amount(p['salePrice']), style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w900)), onTap: () => setState(() => _items.add(SaleItemDraft(name: JsonUtils.str(p['productName']), price: JsonUtils.number(p['salePrice']), productPublicId: JsonUtils.str(p['publicId']))))))
  ]);
}

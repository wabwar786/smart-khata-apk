import 'package:flutter/material.dart';

import '../../services/api_client.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../utils/json_utils.dart';
import '../../widgets/error_box.dart';
import '../../widgets/sk_widgets.dart';

class YourShopScreen extends StatefulWidget {
  const YourShopScreen({super.key});
  @override
  State<YourShopScreen> createState() => _YourShopScreenState();
}

class _YourShopScreenState extends State<YourShopScreen> {
  bool _loading = true;
  String _error = '';
  Map<String, dynamic>? _shop;
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = ''; });
    try {
      final shopRes = await ApiClient.instance.get('/api/shop/profile');
      final orderRes = await ApiClient.instance.get('/api/shop/orders');
      setState(() {
        _shop = JsonUtils.map(shopRes['data']);
        if (_shop!.isEmpty) _shop = null;
        _orders = JsonUtils.list(orderRes['data']).map((e) => JsonUtils.map(e)).toList();
      });
    } catch (e) { setState(() => _error = e.toString()); }
    finally { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _createShop() async {
    final saved = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => ShopProfileForm(existing: _shop)));
    if (saved == true) await _load();
  }

  Future<void> _status(String orderId, String status) async {
    try { await ApiClient.instance.patch('/api/shop/orders/$orderId/status', {'status': status}); await _load(); }
    catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return RefreshIndicator(onRefresh: _load, child: ListView(padding: const EdgeInsets.all(16), children: [
      ErrorBox(_error),
      if (_shop == null) ...[
        Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)), child: Column(children: [
          const SkLogo(size: 76), const SizedBox(height: 18), const Text('Create Your Shop', style: AppText.h2), const SizedBox(height: 8),
          const Text('Generate unique shop code/link. Customers can open your shop and create orders from Smart Khata customer app later.', textAlign: TextAlign.center, style: AppText.small),
          const SizedBox(height: 18), PillButton(text: 'CREATE SHOP PROFILE', icon: Icons.storefront_rounded, onTap: _createShop),
        ])),
      ] else ...[
        _shopHeader(), const SizedBox(height: 14),
        Row(children: [Expanded(child: PillButton(text: 'EDIT SHOP', icon: Icons.edit_rounded, outlined: true, color: AppColors.primary, onTap: _createShop)), const SizedBox(width: 10), Expanded(child: PillButton(text: 'SHARE CODE', icon: Icons.share_rounded, onTap: () { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Shop code: ${JsonUtils.str(_shop!['shopCode'] ?? _shop!['shop_code'])}'))); }))]),
        const SizedBox(height: 20),
        const Text('Customer Orders', style: AppText.h2), const SizedBox(height: 10),
        if (_orders.isEmpty) const SizedBox(height: 260, child: EmptyState(icon: Icons.shopping_bag_outlined, title: 'No orders yet', subtitle: 'Orders from your shop will appear here.')),
        for (final o in _orders) _orderTile(o),
      ],
    ]));
  }

  Widget _shopHeader() {
    final code = JsonUtils.str(_shop!['shopCode'] ?? _shop!['shop_code']);
    return Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(26)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.storefront_rounded, color: AppColors.primary)), const SizedBox(width: 12), Expanded(child: Text(JsonUtils.str(_shop!['shopName'] ?? _shop!['shop_name']), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900))), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.white.withAlpha(25), borderRadius: BorderRadius.circular(12)), child: Text(code, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)))]),
      const SizedBox(height: 12), Text(JsonUtils.str(_shop!['description'], 'Share this shop code with customers.'), style: const TextStyle(color: Colors.white70, fontSize: 12.5)),
      const SizedBox(height: 12), Row(children: [const Icon(Icons.phone_rounded, color: Colors.white70, size: 16), const SizedBox(width: 6), Text(JsonUtils.str(_shop!['contactNumber'] ?? _shop!['contact_number']), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)), const Spacer(), Icon(JsonUtils.str(_shop!['deliveryAvailable'] ?? _shop!['delivery_available']) == 'true' ? Icons.delivery_dining_rounded : Icons.store_rounded, color: Colors.white70, size: 18)]),
    ]));
  }

  Widget _orderTile(Map<String, dynamic> o) {
    final status = JsonUtils.str(o['status']);
    final id = JsonUtils.str(o['publicId'] ?? o['public_id']);
    return Card(margin: const EdgeInsets.only(bottom: 10), child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Expanded(child: Text(JsonUtils.str(o['customerName'] ?? o['customer_name']), style: AppText.h3)), _statusChip(status)]),
      const SizedBox(height: 6), Text('${JsonUtils.str(o['customerPhone'] ?? o['customer_phone'])} • ${Formatters.date(o['createdAt'] ?? o['created_at'])}', style: AppText.small),
      const SizedBox(height: 8), Text('Total: ${Formatters.amount(o['totalAmount'] ?? o['total_amount'])}', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary)),
      const SizedBox(height: 10), Row(children: [if (status == 'NEW') Expanded(child: PillButton(text: 'ACCEPT', icon: Icons.check_rounded, onTap: () => _status(id, 'ACCEPTED'))), if (status == 'NEW') const SizedBox(width: 10), if (status == 'NEW') Expanded(child: PillButton(text: 'REJECT', icon: Icons.close_rounded, outlined: true, color: AppColors.orange, onTap: () => _status(id, 'REJECTED'))), if (status == 'ACCEPTED') Expanded(child: PillButton(text: 'COMPLETE ORDER', icon: Icons.done_all_rounded, onTap: () => _status(id, 'COMPLETED')))]),
    ])));
  }

  Widget _statusChip(String s) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: (s == 'NEW' ? AppColors.orange : s == 'COMPLETED' ? AppColors.green : AppColors.primary).withAlpha(20), borderRadius: BorderRadius.circular(20)), child: Text(s, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: s == 'NEW' ? AppColors.orange : s == 'COMPLETED' ? AppColors.green : AppColors.primary)));
}

class ShopProfileForm extends StatefulWidget {
  final Map<String, dynamic>? existing;
  const ShopProfileForm({super.key, this.existing});
  @override
  State<ShopProfileForm> createState() => _ShopProfileFormState();
}

class _ShopProfileFormState extends State<ShopProfileForm> {
  final _name = TextEditingController();
  final _address = TextEditingController();
  final _contact = TextEditingController();
  final _whatsapp = TextEditingController();
  final _category = TextEditingController();
  final _description = TextEditingController();
  bool _delivery = true;
  bool _saving = false;
  String _error = '';
  @override
  void initState() { super.initState(); final e = widget.existing; if (e != null) { _name.text = JsonUtils.str(e['shopName'] ?? e['shop_name']); _address.text = JsonUtils.str(e['address']); _contact.text = JsonUtils.str(e['contactNumber'] ?? e['contact_number']); _whatsapp.text = JsonUtils.str(e['whatsappNumber'] ?? e['whatsapp_number']); _category.text = JsonUtils.str(e['businessCategory'] ?? e['business_category']); _description.text = JsonUtils.str(e['description']); _delivery = '${e['deliveryAvailable'] ?? e['delivery_available']}' != 'false'; } }
  @override
  void dispose() { _name.dispose(); _address.dispose(); _contact.dispose(); _whatsapp.dispose(); _category.dispose(); _description.dispose(); super.dispose(); }
  Future<void> _save() async {
    if (_name.text.trim().isEmpty) { setState(() => _error = 'Shop name is required.'); return; }
    setState(() { _saving = true; _error = ''; });
    try { await ApiClient.instance.post('/api/shop/profile', {'shopName': _name.text.trim(), 'address': _address.text.trim(), 'contactNumber': _contact.text.trim(), 'whatsappNumber': _whatsapp.text.trim(), 'businessCategory': _category.text.trim(), 'description': _description.text.trim(), 'deliveryAvailable': _delivery}); if (!mounted) return; Navigator.pop(context, true); }
    catch (e) { setState(() => _error = e.toString()); }
    finally { if (mounted) setState(() => _saving = false); }
  }
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Shop Profile')), body: SafeArea(child: ListView(padding: const EdgeInsets.all(18), children: [
    ErrorBox(_error),
    Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)), child: Column(children: [
      TextField(controller: _name, decoration: const InputDecoration(labelText: 'Shop name *', prefixIcon: Icon(Icons.storefront_rounded))), const SizedBox(height: 12),
      TextField(controller: _contact, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Contact number', prefixIcon: Icon(Icons.phone_rounded))), const SizedBox(height: 12),
      TextField(controller: _whatsapp, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'WhatsApp number', prefixIcon: Icon(Icons.chat_rounded))), const SizedBox(height: 12),
      TextField(controller: _category, decoration: const InputDecoration(labelText: 'Business category', prefixIcon: Icon(Icons.category_rounded))), const SizedBox(height: 12),
      TextField(controller: _address, decoration: const InputDecoration(labelText: 'Shop address', prefixIcon: Icon(Icons.location_on_outlined))), const SizedBox(height: 12),
      TextField(controller: _description, maxLines: 3, decoration: const InputDecoration(labelText: 'Shop description', prefixIcon: Icon(Icons.description_outlined))),
      SwitchListTile(contentPadding: EdgeInsets.zero, value: _delivery, onChanged: (v) => setState(() => _delivery = v), title: const Text('Delivery available'), subtitle: const Text('Customer can request delivery')),
    ])), const SizedBox(height: 18), PillButton(text: _saving ? 'SAVING...' : 'SAVE SHOP', icon: Icons.check_rounded, onTap: _saving ? null : _save)
  ])));
}

import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import '../../services/api_client.dart';
import '../../theme/app_theme.dart';
import '../../utils/json_utils.dart';
import '../../widgets/error_box.dart';
import '../../widgets/sk_widgets.dart';
import 'party_action_screen.dart';

class AddPartyScreen extends StatefulWidget {
  final String partyType;
  const AddPartyScreen({super.key, required this.partyType});
  @override
  State<AddPartyScreen> createState() => _AddPartyScreenState();
}

class _AddPartyScreenState extends State<AddPartyScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  bool _loading = false;
  String _error = '';
  bool get _isCustomer => widget.partyType == 'customer';

  @override
  void dispose() { _name.dispose(); _phone.dispose(); _address.dispose(); super.dispose(); }

  Future<void> _importContact() async {
    try {
      final ok = await FlutterContacts.requestPermission(readonly: true);
      if (!ok) { setState(() => _error = 'Contacts permission denied. You can add manually.'); return; }
      final contacts = await FlutterContacts.getContacts(withProperties: true);
      if (!mounted) return;
      final selected = await showModalBottomSheet<Contact>(
        context: context,
        showDragHandle: true,
        builder: (_) => ListView.builder(
          itemCount: contacts.length,
          itemBuilder: (_, i) {
            final c = contacts[i];
            final phone = c.phones.isNotEmpty ? c.phones.first.number : '';
            if (phone.isEmpty) return const SizedBox.shrink();
            return ListTile(title: Text(c.displayName), subtitle: Text(phone), onTap: () => Navigator.pop(context, c));
          },
        ),
      );
      if (selected != null) {
        _name.text = selected.displayName;
        _phone.text = selected.phones.isNotEmpty ? selected.phones.first.number : '';
      }
    } catch (_) { setState(() => _error = 'Unable to read contacts. Please add manually.'); }
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty || _phone.text.trim().isEmpty) { setState(() => _error = 'Name and mobile number are required.'); return; }
    setState(() { _loading = true; _error = ''; });
    try {
      final path = _isCustomer ? '/api/customers' : '/api/suppliers';
      final body = _isCustomer ? {
        'customerName': _name.text.trim(), 'phoneNumber': _phone.text.trim(), 'whatsAppNumber': _phone.text.trim(), 'address': _address.text.trim(), 'openingBalance': 0,
      } : {
        'supplierName': _name.text.trim(), 'phoneNumber': _phone.text.trim(), 'whatsAppNumber': _phone.text.trim(), 'address': _address.text.trim(), 'openingBalance': 0,
      };
      final res = await ApiClient.instance.post(path, body);
      final data = JsonUtils.map(res['data']);
      final id = JsonUtils.str(data['publicId'] ?? data['public_id']);
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => PartyActionScreen(partyType: widget.partyType, publicId: id, name: _name.text.trim(), phone: _phone.text.trim(), justCreated: true)));
    } catch (e) { setState(() => _error = e.toString()); }
    finally { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isCustomer ? 'Add Customer' : 'Add Supplier';
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.all(18), children: [
          ErrorBox(_error),
          Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(_isCustomer ? 'Import from Phone Contacts' : 'Import supplier from Contacts', style: AppText.h3),
            const SizedBox(height: 8),
            Text(_isCustomer ? 'Select customer from your mobile contacts or add manually.' : 'Select supplier from your phone contacts or add manually.', style: AppText.small),
            const SizedBox(height: 12),
            PillButton(text: 'IMPORT FROM CONTACTS', icon: Icons.contacts_rounded, outlined: true, color: AppColors.primary, onTap: _importContact),
          ])),
          const SizedBox(height: 14),
          Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('Manual ${_isCustomer ? 'Customer' : 'Supplier'} Form', style: AppText.h3),
            const SizedBox(height: 14),
            TextField(controller: _name, decoration: InputDecoration(labelText: _isCustomer ? 'Customer name *' : 'Supplier name *', prefixIcon: const Icon(Icons.person_outline_rounded))),
            const SizedBox(height: 12),
            TextField(controller: _phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Mobile number *', prefixIcon: Icon(Icons.phone_rounded))),
            const SizedBox(height: 12),
            TextField(controller: _address, decoration: const InputDecoration(labelText: 'Address', prefixIcon: Icon(Icons.location_on_outlined))),
          ])),
          const SizedBox(height: 18),
          PillButton(text: _loading ? 'SAVING...' : 'SAVE & NEXT', icon: Icons.arrow_forward_rounded, onTap: _loading ? null : _save),
        ]),
      ),
    );
  }
}

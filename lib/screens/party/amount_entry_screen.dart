import 'package:flutter/material.dart';

import '../../services/api_client.dart';
import '../../theme/app_theme.dart';
import '../../widgets/error_box.dart';
import '../../widgets/sk_widgets.dart';

class AmountEntryScreen extends StatefulWidget {
  final String partyType;
  final String partyId;
  final String partyName;
  final String actionType;
  const AmountEntryScreen({super.key, required this.partyType, required this.partyId, required this.partyName, required this.actionType});
  @override
  State<AmountEntryScreen> createState() => _AmountEntryScreenState();
}

class _AmountEntryScreenState extends State<AmountEntryScreen> {
  final _amount = TextEditingController();
  final _note = TextEditingController();
  bool _loading = false;
  String _error = '';
  @override
  void dispose() { _amount.dispose(); _note.dispose(); super.dispose(); }

  Future<void> _save() async {
    final amount = double.tryParse(_amount.text.trim()) ?? 0;
    if (amount <= 0) { setState(() => _error = 'Please enter valid amount.'); return; }
    setState(() { _loading = true; _error = ''; });
    try {
      if (widget.partyType == 'customer') {
        if (widget.actionType == 'received') {
          await ApiClient.instance.post('/api/payments', {'customerPublicId': widget.partyId, 'amount': amount, 'paymentMethod': 'Cash', 'description': _note.text.trim().isEmpty ? 'Payment received' : _note.text.trim()});
        } else {
          await ApiClient.instance.post('/api/cashbook', {'entryType': 'CASH_OUT', 'amount': amount, 'title': 'Paid to ${widget.partyName}', 'description': _note.text.trim()});
        }
      } else {
        if (widget.actionType == 'paid') {
          await ApiClient.instance.post('/api/suppliers/${widget.partyId}/payment', {'amount': amount, 'paymentMethod': 'Cash', 'description': _note.text.trim().isEmpty ? 'Payment to supplier' : _note.text.trim()});
        } else {
          await ApiClient.instance.post('/api/cashbook', {'entryType': 'CASH_IN', 'amount': amount, 'title': 'Received from ${widget.partyName}', 'description': _note.text.trim()});
        }
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Entry saved successfully.')));
      Navigator.pop(context, true);
    } catch (e) { setState(() => _error = e.toString()); }
    finally { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.actionType == 'paid' ? 'Amount Dena Hai' : 'Payment Leni Hai')),
      body: SafeArea(child: ListView(padding: const EdgeInsets.all(18), children: [
        ErrorBox(_error),
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(widget.partyName, style: AppText.h2),
          const SizedBox(height: 14),
          TextField(controller: _amount, keyboardType: TextInputType.number, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900), decoration: const InputDecoration(labelText: 'Amount', prefixText: 'Rs. ', prefixIcon: Icon(Icons.payments_rounded))),
          const SizedBox(height: 12),
          TextField(controller: _note, maxLines: 3, decoration: const InputDecoration(labelText: 'Note', prefixIcon: Icon(Icons.notes_rounded))),
        ])),
        const SizedBox(height: 18),
        PillButton(text: _loading ? 'SAVING...' : 'SAVE TRANSACTION', icon: Icons.check_rounded, onTap: _loading ? null : _save),
      ])),
    );
  }
}

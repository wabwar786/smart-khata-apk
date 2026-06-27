import 'package:flutter/material.dart';

import '../../models/customer.dart';
import '../../services/api_client.dart';
import '../../utils/formatters.dart';
import '../../utils/json_utils.dart';
import '../../widgets/error_box.dart';
import '../../widgets/loading_button.dart';

class ReceivePaymentScreen extends StatefulWidget {
  final Customer? customer;
  const ReceivePaymentScreen({super.key, this.customer});

  @override
  State<ReceivePaymentScreen> createState() => _ReceivePaymentScreenState();
}

class _ReceivePaymentScreenState extends State<ReceivePaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _reference = TextEditingController();
  final _description = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  String _error = '';
  List<Customer> _customers = [];
  Customer? _selectedCustomer;
  String _paymentMethod = 'Cash';

  @override
  void initState() {
    super.initState();
    _selectedCustomer = widget.customer;
    _loadCustomers();
  }

  @override
  void dispose() {
    _amount.dispose();
    _reference.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    setState(() { _loading = true; _error = ''; });
    try {
      final res = await ApiClient.instance.get('/api/customers', query: {'limit': 300});
      final rows = JsonUtils.list(res['data']);
      final customers = rows.map((e) => Customer.fromJson(JsonUtils.map(e))).toList();
      setState(() {
        _customers = customers;
        if (widget.customer != null) {
          for (final c in customers) {
            if (c.publicId == widget.customer!.publicId) {
              _selectedCustomer = c;
              break;
            }
          }
        }
        _selectedCustomer ??= customers.isNotEmpty ? customers.first : null;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCustomer == null) { setState(() => _error = 'Please add/select customer first.'); return; }
    setState(() { _saving = true; _error = ''; });
    try {
      await ApiClient.instance.post('/api/payments', {
        'customerPublicId': _selectedCustomer!.publicId,
        'amount': double.tryParse(_amount.text.trim()) ?? 0,
        'paymentMethod': _paymentMethod,
        'referenceNo': _reference.text.trim(),
        'description': _description.text.trim().isEmpty ? 'Payment received' : _description.text.trim(),
      });
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Receive Payment')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ErrorBox(_error),
                    DropdownButtonFormField<Customer>(
                      value: _selectedCustomer,
                      decoration: const InputDecoration(labelText: 'Customer'),
                      items: _customers.map((c) => DropdownMenuItem<Customer>(value: c, child: Text('${c.customerName} • ${Formatters.amount(c.currentBalance)}'))).toList(),
                      onChanged: widget.customer == null ? (v) => setState(() => _selectedCustomer = v) : null,
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(controller: _amount, decoration: const InputDecoration(labelText: 'Amount', prefixIcon: Icon(Icons.payments_outlined)), keyboardType: TextInputType.number, validator: (v) => (double.tryParse(v ?? '') ?? 0) <= 0 ? 'Invalid amount' : null),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(value: _paymentMethod, decoration: const InputDecoration(labelText: 'Payment Method'), items: const ['Cash','Bank','JazzCash','EasyPaisa','Card','Cheque'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => _paymentMethod = v ?? 'Cash')),
                    const SizedBox(height: 12),
                    TextFormField(controller: _reference, decoration: const InputDecoration(labelText: 'Reference No / Cheque No')),
                    const SizedBox(height: 12),
                    TextFormField(controller: _description, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
                    const SizedBox(height: 18),
                    LoadingButton(loading: _saving, text: 'Save Payment', onPressed: _save),
                  ],
                ),
              ),
            ),
    );
  }
}

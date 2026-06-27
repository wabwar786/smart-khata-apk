import 'package:flutter/material.dart';

import '../../services/api_client.dart';
import '../../widgets/error_box.dart';
import '../../widgets/loading_button.dart';

class CustomerFormScreen extends StatefulWidget {
  const CustomerFormScreen({super.key});

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _whatsapp = TextEditingController();
  final _city = TextEditingController();
  final _openingBalance = TextEditingController(text: '0');
  final _creditLimit = TextEditingController();
  final _notes = TextEditingController();
  bool _loading = false;
  String _error = '';

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _whatsapp.dispose();
    _city.dispose();
    _openingBalance.dispose();
    _creditLimit.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      await ApiClient.instance.post('/api/customers', {
        'customerName': _name.text.trim(),
        'phoneNumber': _phone.text.trim(),
        'whatsAppNumber': _whatsapp.text.trim().isEmpty ? _phone.text.trim() : _whatsapp.text.trim(),
        'city': _city.text.trim(),
        'openingBalance': double.tryParse(_openingBalance.text.trim()) ?? 0,
        'creditLimit': _creditLimit.text.trim().isEmpty ? null : double.tryParse(_creditLimit.text.trim()),
        'notes': _notes.text.trim(),
      });
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Customer')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ErrorBox(_error),
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Customer Name'),
                validator: (v) => v == null || v.trim().length < 2 ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(controller: _phone, decoration: const InputDecoration(labelText: 'Phone Number'), keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              TextFormField(controller: _whatsapp, decoration: const InputDecoration(labelText: 'WhatsApp Number'), keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              TextFormField(controller: _city, decoration: const InputDecoration(labelText: 'City')),
              const SizedBox(height: 12),
              TextFormField(controller: _openingBalance, decoration: const InputDecoration(labelText: 'Opening Balance'), keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              TextFormField(controller: _creditLimit, decoration: const InputDecoration(labelText: 'Credit Limit'), keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              TextFormField(controller: _notes, decoration: const InputDecoration(labelText: 'Notes'), maxLines: 3),
              const SizedBox(height: 18),
              LoadingButton(loading: _loading, text: 'Save Customer', onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}

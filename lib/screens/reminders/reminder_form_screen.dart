import 'package:flutter/material.dart';

import '../../models/customer.dart';
import '../../services/api_client.dart';
import '../../utils/json_utils.dart';
import '../../widgets/error_box.dart';
import '../../widgets/loading_button.dart';

class ReminderFormScreen extends StatefulWidget {
  const ReminderFormScreen({super.key});

  @override
  State<ReminderFormScreen> createState() => _ReminderFormScreenState();
}

class _ReminderFormScreenState extends State<ReminderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  String _error = '';
  String _type = 'PAYMENT_DUE';
  DateTime _dateTime = DateTime.now().add(const Duration(days: 1));
  List<Customer> _customers = [];
  Customer? _customer;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    try {
      final res = await ApiClient.instance.get('/api/customers', query: {'limit': 200});
      final rows = JsonUtils.list(res['data']);
      setState(() => _customers = rows.map((e) => Customer.fromJson(JsonUtils.map(e))).toList());
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(context: context, firstDate: DateTime.now().subtract(const Duration(days: 1)), lastDate: DateTime.now().add(const Duration(days: 3650)), initialDate: _dateTime);
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_dateTime));
    setState(() => _dateTime = DateTime(date.year, date.month, date.day, time?.hour ?? _dateTime.hour, time?.minute ?? _dateTime.minute));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _saving = true; _error = ''; });
    try {
      await ApiClient.instance.post('/api/reminders', {
        'reminderType': _type,
        'title': _title.text.trim(),
        'description': _description.text.trim(),
        'reminderDateTime': _dateTime.toIso8601String(),
        'customerPublicId': _customer?.publicId,
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
      appBar: AppBar(title: const Text('Add Reminder')),
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
                    DropdownButtonFormField<String>(value: _type, decoration: const InputDecoration(labelText: 'Reminder Type'), items: const ['PAYMENT_DUE','QUOTATION_FOLLOWUP','CHEQUE','GENERAL'].map((e) => DropdownMenuItem(value: e, child: Text(e.replaceAll('_', ' ')))).toList(), onChanged: (v) => setState(() => _type = v ?? 'PAYMENT_DUE')),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<Customer?>(value: _customer, decoration: const InputDecoration(labelText: 'Customer (optional)'), items: [const DropdownMenuItem<Customer?>(value: null, child: Text('No customer')), ..._customers.map((c) => DropdownMenuItem<Customer?>(value: c, child: Text(c.customerName)))], onChanged: (v) => setState(() => _customer = v)),
                    const SizedBox(height: 12),
                    TextFormField(controller: _title, decoration: const InputDecoration(labelText: 'Title'), validator: (v) => v == null || v.trim().length < 2 ? 'Required' : null),
                    const SizedBox(height: 12),
                    TextFormField(controller: _description, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
                    const SizedBox(height: 12),
                    Card(child: ListTile(leading: const Icon(Icons.calendar_month_rounded), title: const Text('Reminder Date/Time'), subtitle: Text(_dateTime.toLocal().toString().substring(0, 16)), trailing: const Icon(Icons.edit_rounded), onTap: _pickDate)),
                    const SizedBox(height: 18),
                    LoadingButton(loading: _saving, text: 'Save Reminder', onPressed: _save),
                  ],
                ),
              ),
            ),
    );
  }
}

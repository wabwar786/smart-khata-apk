import 'package:flutter/material.dart';

import '../../services/api_client.dart';
import '../../utils/formatters.dart';
import '../../utils/json_utils.dart';

class ModuleField {
  final String key;
  final String label;
  final TextInputType keyboardType;
  final bool required;

  const ModuleField({
    required this.key,
    required this.label,
    this.keyboardType = TextInputType.text,
    this.required = false,
  });
}

class ModuleConfig {
  final String title;
  final String subtitle;
  final String endpoint;
  final IconData icon;
  final List<ModuleField> fields;
  final bool canAdd;

  const ModuleConfig({
    required this.title,
    required this.subtitle,
    required this.endpoint,
    required this.icon,
    this.fields = const [],
    this.canAdd = false,
  });
}

class SimpleModuleScreen extends StatefulWidget {
  final ModuleConfig config;
  const SimpleModuleScreen({super.key, required this.config});

  @override
  State<SimpleModuleScreen> createState() => _SimpleModuleScreenState();
}

class _SimpleModuleScreenState extends State<SimpleModuleScreen> {
  bool _loading = true;
  String _error = '';
  List<Map<String, dynamic>> _rows = [];

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
      final res = await ApiClient.instance.get(widget.config.endpoint);
      setState(() => _rows = JsonUtils.list(res['data']).map((e) => JsonUtils.map(e)).toList());
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _add() async {
    final body = <String, dynamic>{};
    final controllers = <String, TextEditingController>{};
    for (final field in widget.config.fields) {
      controllers[field.key] = TextEditingController();
    }

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add ${widget.config.title}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.config.fields.map((field) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TextField(
                  controller: controllers[field.key],
                  keyboardType: field.keyboardType,
                  decoration: InputDecoration(labelText: field.label),
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              for (final field in widget.config.fields) {
                final value = controllers[field.key]!.text.trim();
                if (field.required && value.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${field.label} is required')));
                  return;
                }
                if (value.isNotEmpty) {
                  if (field.keyboardType == TextInputType.number) {
                    body[field.key] = double.tryParse(value) ?? value;
                  } else {
                    body[field.key] = value;
                  }
                }
              }
              try {
                await ApiClient.instance.post(widget.config.endpoint, body);
                if (context.mounted) Navigator.pop(context, true);
              } catch (e) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    for (final c in controllers.values) {
      c.dispose();
    }
    if (saved == true) _load();
  }

  String _titleFor(Map<String, dynamic> row) {
    for (final key in ['customer_name', 'supplier_name', 'product_name', 'account_name', 'branch_name', 'full_name', 'title', 'subject', 'purchase_no', 'invoice_no', 'cheque_no', 'category_name', 'payroll_month']) {
      final v = row[key];
      if (v != null && v.toString().trim().isNotEmpty) return v.toString();
    }
    return widget.config.title;
  }

  String _subtitleFor(Map<String, dynamic> row) {
    final parts = <String>[];
    for (final key in ['phone_number', 'whatsapp_number', 'entry_type', 'account_type', 'status', 'payment_status', 'created_at', 'city']) {
      final v = row[key];
      if (v != null && v.toString().trim().isNotEmpty) parts.add(_nice(v));
      if (parts.length >= 2) break;
    }
    return parts.isEmpty ? widget.config.subtitle : parts.join(' • ');
  }

  String _amountFor(Map<String, dynamic> row) {
    for (final key in ['current_balance', 'amount', 'grand_total', 'net_amount', 'sale_price', 'total_sales']) {
      if (row[key] != null) return Formatters.amount(JsonUtils.number(row[key]));
    }
    if (row['current_stock'] != null) return JsonUtils.str(row['current_stock'], '0');
    return '';
  }

  String _nice(dynamic value) {
    final text = value.toString();
    if (RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(text)) return Formatters.date(text);
    return text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.config.title)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        ElevatedButton(onPressed: _load, child: const Text('Retry')),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              CircleAvatar(child: Icon(widget.config.icon)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(widget.config.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                                    const SizedBox(height: 3),
                                    Text(widget.config.subtitle, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                                  ],
                                ),
                              ),
                              Text('${_rows.length}', style: const TextStyle(fontWeight: FontWeight.w900)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_rows.isEmpty)
                        const SizedBox(height: 220, child: Center(child: Text('No records yet.')))
                      else
                        ..._rows.map((row) {
                          final amount = _amountFor(row);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Card(
                              child: ListTile(
                                leading: CircleAvatar(backgroundColor: const Color(0xFF0F766E).withOpacity(0.10), child: Icon(widget.config.icon, color: const Color(0xFF0F766E))),
                                title: Text(_titleFor(row), style: const TextStyle(fontWeight: FontWeight.w800)),
                                subtitle: Text(_subtitleFor(row), maxLines: 2, overflow: TextOverflow.ellipsis),
                                trailing: amount.isEmpty ? null : Text(amount, style: const TextStyle(fontWeight: FontWeight.w900)),
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
      floatingActionButton: widget.config.canAdd && widget.config.fields.isNotEmpty
          ? FloatingActionButton.extended(onPressed: _add, icon: const Icon(Icons.add), label: const Text('Add'))
          : null,
    );
  }
}

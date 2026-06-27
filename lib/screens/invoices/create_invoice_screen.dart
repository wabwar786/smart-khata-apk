import 'package:flutter/material.dart';

import '../../models/customer.dart';
import '../../models/product.dart';
import '../../services/api_client.dart';
import '../../utils/formatters.dart';
import '../../widgets/error_box.dart';
import '../../widgets/loading_button.dart';

class CreateInvoiceScreen extends StatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _qty = TextEditingController(text: '1');
  final _unitPrice = TextEditingController(text: '0');
  final _paidAmount = TextEditingController(text: '0');
  final _notes = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  String _error = '';
  List<Customer> _customers = [];
  List<Product> _products = [];
  Customer? _selectedCustomer;
  Product? _selectedProduct;

  @override
  void initState() {
    super.initState();
    _loadMasterData();
  }

  @override
  void dispose() {
    _qty.dispose();
    _unitPrice.dispose();
    _paidAmount.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _loadMasterData() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final customerRes = await ApiClient.instance.get('/api/customers', query: {'limit': 100});
      final productRes = await ApiClient.instance.get('/api/products', query: {'limit': 100});
      final customers = (customerRes['data'] as List<dynamic>? ?? [])
          .map((e) => Customer.fromJson(e as Map<String, dynamic>))
          .toList();
      final products = (productRes['data'] as List<dynamic>? ?? [])
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList();
      setState(() {
        _customers = customers;
        _products = products;
        if (products.isNotEmpty) {
          _selectedProduct = products.first;
          _unitPrice.text = products.first.salePrice;
        }
        if (customers.isNotEmpty) _selectedCustomer = customers.first;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  double get _qtyValue => double.tryParse(_qty.text.trim()) ?? 0;
  double get _unitPriceValue => double.tryParse(_unitPrice.text.trim()) ?? 0;
  double get _total => _qtyValue * _unitPriceValue;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProduct == null) {
      setState(() => _error = 'Please add/select product first.');
      return;
    }
    setState(() {
      _saving = true;
      _error = '';
    });
    try {
      await ApiClient.instance.post('/api/sales-invoices', {
        'customerPublicId': _selectedCustomer?.publicId,
        'customerName': _selectedCustomer == null ? 'Cash Customer' : null,
        'items': [
          {
            'productPublicId': _selectedProduct!.publicId,
            'qty': _qtyValue,
            'unitPrice': _unitPriceValue,
            'discountAmount': 0,
            'taxPercent': 0,
          }
        ],
        'paidAmount': double.tryParse(_paidAmount.text.trim()) ?? 0,
        'paymentMethod': 'Cash',
        'notes': _notes.text.trim(),
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
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Create Invoice')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ErrorBox(_error),
              DropdownButtonFormField<Customer?>(
                value: _selectedCustomer,
                decoration: const InputDecoration(labelText: 'Customer'),
                items: [
                  const DropdownMenuItem<Customer?>(value: null, child: Text('Cash Customer')),
                  ..._customers.map((c) => DropdownMenuItem<Customer?>(value: c, child: Text(c.customerName))),
                ],
                onChanged: (v) => setState(() => _selectedCustomer = v),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Product>(
                value: _selectedProduct,
                decoration: const InputDecoration(labelText: 'Product / Service'),
                items: _products.map((p) => DropdownMenuItem<Product>(value: p, child: Text(p.productName))).toList(),
                onChanged: (v) => setState(() {
                  _selectedProduct = v;
                  if (v != null) _unitPrice.text = v.salePrice;
                }),
                validator: (v) => v == null ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _qty,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                validator: (v) => (double.tryParse(v ?? '') ?? 0) <= 0 ? 'Invalid qty' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _unitPrice,
                decoration: const InputDecoration(labelText: 'Unit Price'),
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                validator: (v) => (double.tryParse(v ?? '') ?? -1) < 0 ? 'Invalid price' : null,
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  title: const Text('Invoice Total'),
                  trailing: Text(Formatters.amount(_total), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(controller: _paidAmount, decoration: const InputDecoration(labelText: 'Paid Amount'), keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              TextFormField(controller: _notes, decoration: const InputDecoration(labelText: 'Notes'), maxLines: 3),
              const SizedBox(height: 18),
              LoadingButton(loading: _saving, text: 'Save Invoice', onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}

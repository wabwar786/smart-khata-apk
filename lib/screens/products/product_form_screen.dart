import 'package:flutter/material.dart';

import '../../services/api_client.dart';
import '../../widgets/error_box.dart';
import '../../widgets/loading_button.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _sku = TextEditingController();
  final _purchasePrice = TextEditingController(text: '0');
  final _salePrice = TextEditingController(text: '0');
  final _openingStock = TextEditingController(text: '0');
  final _lowStock = TextEditingController();
  String _productType = 'PRODUCT';
  bool _loading = false;
  String _error = '';

  @override
  void dispose() {
    _name.dispose();
    _sku.dispose();
    _purchasePrice.dispose();
    _salePrice.dispose();
    _openingStock.dispose();
    _lowStock.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      await ApiClient.instance.post('/api/products', {
        'unitId': 1,
        'productName': _name.text.trim(),
        'sku': _sku.text.trim(),
        'productType': _productType,
        'purchasePrice': double.tryParse(_purchasePrice.text.trim()) ?? 0,
        'salePrice': double.tryParse(_salePrice.text.trim()) ?? 0,
        'openingStock': _productType == 'SERVICE' ? 0 : (double.tryParse(_openingStock.text.trim()) ?? 0),
        'lowStockQty': _lowStock.text.trim().isEmpty ? null : double.tryParse(_lowStock.text.trim()),
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
      appBar: AppBar(title: const Text('Add Product / Service')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ErrorBox(_error),
              DropdownButtonFormField<String>(
                value: _productType,
                decoration: const InputDecoration(labelText: 'Type'),
                items: const [
                  DropdownMenuItem(value: 'PRODUCT', child: Text('Product')),
                  DropdownMenuItem(value: 'SERVICE', child: Text('Service')),
                ],
                onChanged: (v) => setState(() => _productType = v ?? 'PRODUCT'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Product / Service Name'),
                validator: (v) => v == null || v.trim().length < 2 ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(controller: _sku, decoration: const InputDecoration(labelText: 'SKU / Code')),
              const SizedBox(height: 12),
              TextFormField(controller: _purchasePrice, decoration: const InputDecoration(labelText: 'Purchase Price'), keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              TextFormField(controller: _salePrice, decoration: const InputDecoration(labelText: 'Sale Price'), keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              if (_productType == 'PRODUCT') ...[
                TextFormField(controller: _openingStock, decoration: const InputDecoration(labelText: 'Opening Stock'), keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                TextFormField(controller: _lowStock, decoration: const InputDecoration(labelText: 'Low Stock Alert Qty'), keyboardType: TextInputType.number),
                const SizedBox(height: 12),
              ],
              LoadingButton(loading: _loading, text: 'Save Product', onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}
